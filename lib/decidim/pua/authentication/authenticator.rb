# Copyright (C) 2023 Formez PA
# This program is free software: you can redistribute it and/or modify it under the terms of the GNU Affero General Public License as published by the Free Software Foundation, version 3.
# This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU Affero General Public License for more details.
# You should have received a copy of the GNU Affero General Public License along with this program. If not, see <https://www.gnu.org/licenses/>

# frozen_string_literal: true

# Verifica i dati dell'utente provenienti dal PUA

module Decidim
  module Pua
    module Authentication
      class Authenticator
        include ActiveModel::Validations

        def initialize(tenant, organization, oauth_hash)
          @tenant = tenant
          @organization = organization
          @oauth_hash = oauth_hash
          @new_user = false
        end

        def verified_email
          @verified_email ||= oauth_data[:info][:email].try(:downcase)
        end

        def user_params_from_oauth_hash
          return nil if oauth_data.empty?
          return nil if user_identifier.blank?

          {
            provider: oauth_data[:provider],
            uid: user_identifier,
            # name: oauth_data[:info][:name],
            # nickname: oauth_data[:info][:nickname] || oauth_data[:info][:name],
            oauth_signature: user_signature,
            avatar_url: oauth_data[:info][:image],
            raw_data: oauth_hash
          }
        end

        def validate!
          raise ValidationError, "No data provided" unless attributes

          data_blank = attributes.values.all? { |val| val.blank? }
          raise ValidationError, "Invalid SAML data" if data_blank
          raise ValidationError, "Invalid person dentifier" if person_identifier_digest.blank?

          id = ::Decidim::Identity.find_by(
            organization: organization,
            provider: oauth_data[:provider],
            uid: user_identifier
          )
          spid_code = attributes[:providersubject]
          current_provider = attributes[:providername]
          if id.nil? && spid_code && current_provider && !["CIE", "CNS"].include?(current_provider)
            id = ::Decidim::Identity.find_by(
              organization: organization,
              uid: attributes[:providersubject]
            )
          end
          @new_user = id ? id.user.blank? : true

          true
        end

        def identify_user!(user)
          identity = user.identities.find_by(
            organization: organization,
            provider: oauth_data[:provider],
            uid: user_identifier
          )
          return identity if identity

          # Check that the identity is not already bound to another user.
          id = ::Decidim::Identity.find_by(
            organization: organization,
            provider: oauth_data[:provider],
            uid: user_identifier
          )

          raise IdentityBoundToOtherUserError if id

          user.identities.create!(
            organization: organization,
            provider: oauth_data[:provider],
            uid: user_identifier
          )
        end

        def authorize_user!(user)
          authorization = ::Decidim::Authorization.find_by(
            name: "#{tenant.name}_identity",
            unique_id: user_signature
          )
          if authorization
            raise AuthorizationBoundToOtherUserError if authorization.user != user
          else
            authorization = ::Decidim::Authorization.find_or_initialize_by(
              name: "#{tenant.name}_identity",
              user: user
            )
          end

          authorization.attributes = {
            unique_id: user_signature,
            metadata: authorization_metadata
          }
          authorization.save!
          authorization.grant!

          authorization
        end

        def update_user!(user)
          user_changed = false
          if user.email != verified_email
            user_changed = true
            user.email = verified_email
            user.skip_reconfirmation!
          end

          user.save! if user_changed
        end

        protected

        attr_reader :organization, :tenant, :oauth_hash

        def oauth_data
          @oauth_data ||= oauth_hash.slice(:provider, :uid, :info)
        end

        def attributes
          @attributes ||= oauth_hash[:extra][:raw_info]
        end

        def user_identifier
          @user_identifier ||= oauth_data[:uid]
        end

        def user_signature
          @user_signature ||= ::Decidim::OmniauthRegistrationForm.create_signature(
            oauth_data[:provider],
            user_identifier
          )
        end

        def metadata_collector
          @metadata_collector ||= tenant.metadata_collector_for(attributes)
        end

        def authorization_metadata
          metadata_collector.metadata
        end

        def person_identifier_digest
          return if user_identifier.blank?

          @person_identifier_digest ||= Digest::MD5.hexdigest(
            "#{tenant.name.upcase}:#{user_identifier}:#{Rails.application.secrets.secret_key_base}"
          )
        end
      end
    end
  end
end