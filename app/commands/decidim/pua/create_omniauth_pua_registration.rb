# Copyright (C) 2023 Formez PA
# This program is free software: you can redistribute it and/or modify it under the terms of the GNU Affero General Public License as published by the Free Software Foundation, version 3.
# This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU Affero General Public License for more details.
# You should have received a copy of the GNU Affero General Public License along with this program. If not, see <https://www.gnu.org/licenses/>

# frozen_string_literal: true

# ridefinizione del create_or_find_user per aggiungere la notifica email

module Decidim
  module Pua
    class CreateOmniauthPuaRegistration < ::Decidim::CreateOmniauthRegistration

      private

      def create_or_find_user
        generated_password = SecureRandom.hex

        @user = User.find_or_initialize_by(
          email: verified_email,
          organization: organization
        )

        if persisted = @user.persisted?
          @user.skip_confirmation! if !@user.confirmed? && @user.email == verified_email
          # @user.nickname = form.normalized_nickname if form.invitation_token.present?
          # @user.name = form.name if form.invitation_token.present?
          @user.name = form.name
          @user.nickname = form.nickname
          @user.password = generated_password
          @user.password_confirmation = generated_password
        else
          @user.email = (verified_email || form.email)
          @user.name = form.name
          @user.nickname = form.normalized_nickname
          @user.newsletter_notifications_at = nil
          @user.email_on_notification = true
          @user.password = generated_password
          @user.password_confirmation = generated_password
          if form.avatar_url.present?
            url = URI.parse(form.avatar_url)
            filename = File.basename(url.path)
            file = URI.open(url)
            @user.avatar.attach(io: file, filename: filename)
          end
          @user.skip_confirmation! if verified_email
        end

        @user.tos_agreement = "1"
        @user.save! && persisted && !@user.must_log_with_pua? && Decidim::Pua::PuaJob.perform_later(@user)
      end

      def existing_identity
        @existing_identity ||= Identity.find_by(
          user: organization.users,
          provider: form.provider,
          uid: form.uid
        )
        return @existing_identity if @existing_identity

        begin
          data = JSON.parse(form.raw_data)
          spid_code = data.dig("extra", "raw_info", "providersubject")
          current_provider = data.dig("extra", "raw_info", "providername")
          if @existing_identity.nil? && spid_code && current_provider && !["cie", "cns"].include?(current_provider.try(&:downcase))
            @existing_identity = Identity.find_by(
              user: organization.users,
              uid: spid_code
            )
            @user = @existing_identity.try(:user)
            if @existing_identity # Creo nuova identity relativa al PUA
              create_identity
              Decidim::Pua::PuaJob.perform_later(@user)
            end
          end
        rescue ::Exception => e
          Rails.logger.error e.message
          Rails.logger.error e.backtrace.join("\n")
          nil
        end
      end

    end

  end
end
