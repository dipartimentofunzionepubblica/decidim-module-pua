# Copyright (C) 2023 Formez PA
# This program is free software: you can redistribute it and/or modify it under the terms of the GNU Affero General Public License as published by the Free Software Foundation, version 3.
# This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU Affero General Public License for more details.
# You should have received a copy of the GNU Affero General Public License along with this program. If not, see <https://www.gnu.org/licenses/>

# Gestisce il login PUA

module Decidim
  module Pua
    class OmniauthCallbacksController < ::Decidim::Devise::OmniauthRegistrationsController
      helper Decidim::Pua::Engine.routes.url_helpers
      helper_method :omniauth_registrations_path

      skip_before_action :verify_authenticity_token, only: [:pua, :failure]
      skip_after_action :verify_same_origin_request, only: [:pua, :failure]

      def pua
        session["decidim-pua.signed_in"] = true
        session["decidim-pua.tenant"] = tenant.name
        cookies.signed_or_encrypted["_pua_id_token"] = oauth_hash.dig(:credentials, :id_token)

        authenticator.validate!

        if user_signed_in?
          authenticator.identify_user!(current_user)

          # Aggiunge l'autorizzazione per l'utente
          return fail_authorize unless authorize_user(current_user)

          # Aggiorna le informazioni dell'utente
          authenticator.update_user!(current_user)

          sign_in(current_user, bypass: true)
          Decidim::Pua::PuaJob.perform_later(current_user)
          flash[:notice] = t("authorizations.create.success", scope: "decidim.pua.verification")
          return redirect_to(stored_location_for(resource || :user) || decidim.root_path)
        end

        # # Normale richiesta di autorizzazione, procede con la logica di Decidim
        send(:create)

      rescue Decidim::Pua::Authentication::ValidationError => e
        fail_authorize(e.validation_key)
      rescue Decidim::Pua::Authentication::IdentityBoundToOtherUserError
        fail_authorize(:identity_bound_to_other_user)
      end

      def create
        form_params = user_params_from_oauth_hash || params.require(:user).permit!
        Rails.logger.info form_params.inspect
        form_params.merge!(params.require(:user).permit!) if params.dig(:user).present?
        origin = request.env['omniauth.origin'] rescue ''

        spid_code = form_params.dig(:raw_data, :extra, :raw_info, :providersubject)
        current_provider = form_params.dig(:raw_data, :extra, :raw_info, :providername)

        invitation_token = invitation_token(origin) || form_params.dig("invitation_token")
        verified_e = current_provider && !["cie", "cns"].include?(current_provider) ? verified_email : nil


        # nel caso la form di integrazione dati viene presentata
        invited_user = nil
        if invitation_token.present?
          invited_user = resource_class.find_by_invitation_token(invitation_token, true)
          invited_user.nickname = nil # Forzo nickname a nil per invalidare il valore normalizzato di Decidim di default
          form_params[:name] = params.dig(:user, :name).present? ? params.dig(:user, :name) : invited_user.name
          @form = form(OmniauthPuaRegistrationForm).from_params(invited_user.attributes.merge(form_params))
          @form.invitation_token = invitation_token
          @form.email ||= invited_user.email
          verified_e = invited_user.email
        else
          if current_provider && !["cie", "cns"].include?(current_provider) && ( u = current_organization.users.find_by(email: verified_e) )
            form_params[:name] = u.name
            form_params[:nickname] = u.nickname
          else
            form_params[:name] = params.dig(:user, :name) if params.dig(:user, :name).present? && current_provider && !["cie", "cns"].include?(current_provider)
            form_params[:nickname] = params.dig(:user, :nickname) if params.dig(:user, :nickname).present? && current_provider && !["cie", "cns"].include?(current_provider)
          end
          Rails.logger.info form_params.inspect
          @form = form(OmniauthPuaRegistrationForm).from_params(form_params)
          @form.email ||= verified_e
          verified_e ||= current_provider && !["cie", "cns"].include?(current_provider) && form_params.dig(:email)
        end

        # Controllo che non esisti un'altro account con la stessa email utilizzata con PUA
        # in quanto a fine processo all'utente viene aggiornata l'email e il tutto protrebbe essere invalido
        if invited_user.present? && form_params.dig(:raw_data, :info, :email).present? && invited_user.email != form_params.dig(:raw_data, :info, :email) &&
          current_organization.users.where(email: form_params.dig(:raw_data, :info, :email)).where.not(id: invited_user.id).present?
          set_flash_message :alert, :failure, kind: "PUA", reason: t("decidim.devise.omniauth_registrations.create.email_already_exists")
          return redirect_to after_omniauth_failure_path_for(resource_name)
        end

        existing_identity = Identity.find_by(
          user: current_organization.users,
          provider: @form.provider,
          uid: @form.uid
        )

        if existing_identity.nil? && spid_code && current_provider && !["cie", "cns"].include?(current_provider)
          existing_identity = Identity.find_by(
            user: current_organization.users,
            uid: spid_code
          )
        end


        CreateOmniauthPuaRegistration.call(@form, verified_e) do
          on(:ok) do |user|
            # Se l'identità PUA è già utilizzata da un altro account
            if invited_user.present? && invited_user.email != user.email
              set_flash_message :alert, :failure, kind: "PUA", reason: t("decidim.devise.omniauth_registrations.create.email_already_exists")
              return redirect_to after_omniauth_failure_path_for(resource_name)
            end

            # match l'utente dell'invitation token passato come relay_state in PUA Strategy,
            # associo l'identity PUA all'utente creato nell'invitation e aggiorno l'email dell'utente con quella dello PUA.
            if invitation_token.present? && invited_user.present? && invited_user.email == user.email
              # per accettare resource_class.accept_invitation!(devise_parameter_sanitizer.sanitize(:accept_invitation).merge(invitation_token: invitation_token))
              user = resource_class.find_by_invitation_token(invitation_token, true)
              # nuovo utente senza password, fallirebbero le validazioni
              token = ::Devise.friendly_token
              user.password = token
              user.password_confirmation = token
              user.save(validate: false)
              user.accept_invitation!
            end

            if user.active_for_authentication?
              if existing_identity
                Decidim::ActionLogger.log(:login, user, existing_identity, {})
              else
                i = user.identities.find_by(uid: oauth_hash[:uid]) rescue nil
                Decidim::ActionLogger.log(:registration, user, i, {})
              end
              sign_in_and_redirect user, verified_email: verified_e, event: :authentication
              set_flash_message :notice, :success, kind: "PUA"
            else
              expire_data_after_sign_in!
              user.resend_confirmation_instructions unless user.confirmed?
              redirect_to decidim.root_path
              flash[:notice] = t("devise.registrations.signed_up_but_unconfirmed")
            end
          end

          on(:invalid) do |user|
            #set_flash_message :alert, :failure, kind: "PUA", reason: t("decidim.pua.omniauth_callbacks.failure.success_status")
            render :new
          end

          on(:error) do |user|
            set_flash_message :alert, :failure, kind: "PUA", reason: user.errors.full_messages.try(:first)
            render :new
          end
        end
      rescue Decidim::Pua::Authentication::AuthorizationBoundToOtherUserError
        return fail_authorize(:identity_bound_to_other_user)
      end

      def sign_in_and_redirect(resource_or_scope, *args)
        if resource_or_scope.is_a?(::Decidim::User)
          return fail_authorize unless authorize_user(resource_or_scope)

          authenticator.update_user!(resource_or_scope)
        end

        super
      end

      def first_login_and_not_authorized?(_user)
        false
      end

      private

      def authorize_user(user)
        authenticator.authorize_user!(user)
      end

      def fail_authorize(failure_message_key = :already_authorized)
        flash[:alert] = t("failure.#{failure_message_key}", scope: "decidim.pua.omniauth_callbacks")
        redirect_to stored_location_for(resource || :user) || decidim.root_path
      end

      def omniauth_registrations_path(resource)
        decidim_pua.public_send("user_#{current_organization.enabled_omniauth_providers.dig(:pua, :tenant_name)}_omniauth_create_url")
      end

      def user_params_from_oauth_hash
        authenticator.user_params_from_oauth_hash
      end

      def authenticator
        @authenticator ||= tenant.authenticator_for(
          current_organization,
          oauth_hash
        )
      end

      def tenant
      @tenant ||= begin
                    matches = request.path.match(%r{^/users/auth/([^/]+)/.+})
                    raise "Invalid PUA tenant" unless matches

                    name = matches[1]
                    tenant = Decidim::Pua.tenants.find { |t| t.name == name }
                    raise "Unkown PUA tenant: #{name}" unless tenant

                    tenant
                  end
      end

      def invitation_token(url)
        begin
          CGI.parse(URI.parse(url).query).dig('invitation_token').first
        rescue
          nil
        end
      end

      def verified_email
        authenticator.verified_email
      end

      def oauth_hash
        raw_hash = request.env["omniauth.auth"] || JSON.parse(params.dig(:user, :raw_data))
        return {} unless raw_hash

        raw_hash.deep_symbolize_keys
      end
    end
  end
end
