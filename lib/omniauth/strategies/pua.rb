# Copyright (C) 2023 Formez PA
# This program is free software: you can redistribute it and/or modify it under the terms of the GNU Affero General Public License as published by the Free Software Foundation, version 3.
# This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU Affero General Public License for more details.
# You should have received a copy of the GNU Affero General Public License along with this program. If not, see <https://www.gnu.org/licenses/>

# Personalizzazione della strategia omniauth per passare l'id_token in fase di logout

require 'omniauth/openid_connect'

module OmniAuth
  module Strategies
    class Pua < OpenIDConnect

      # Per passare al provider id_token_hint che permette il redirect dopo il logout
      def encoded_post_logout_redirect_uri
        return unless options.post_logout_redirect_uri

        URI.encode_www_form(
          post_logout_redirect_uri: options.post_logout_redirect_uri,
          id_token_hint: session_id_token
        )
      end

      # # Personalizzazione per storare l'id_token in sessione nel Code Flow
      # def access_token
      #   return @access_token if @access_token
      #
      #   token_request_params = {
      #     scope: (options.scope if options.send_scope_to_token_endpoint),
      #     client_auth_method: options.client_auth_method,
      #   }
      #
      #   token_request_params[:code_verifier] = params['code_verifier'] || session.delete('omniauth.pkce.verifier') if options.pkce
      #
      #   @access_token = client.access_token!(token_request_params)
      #   verify_id_token!(@access_token.id_token) if configured_response_type == 'code'
      #     # session['decidim-pua.id_token'] = @access_token.id_token
      #
      #   @access_token
      # end

      # Personalizzazione per storare l'id_token in sessione nell'Implicit Flow
      def id_token_callback_phase
        user_data = decode_id_token(params['id_token']).raw_attributes
        env['omniauth.auth'] = AuthHash.new(
          provider: name,
          uid: user_data['sub'],
          info: { name: user_data['name'], email: user_data['email'] },
          extra: { raw_info: user_data }
        )
        session['decidim-pua.id_token'] = params['id_token']
        call_app!
      end

      # Per personalizzare il path di logout
      def logout_path_pattern
        @logout_path_pattern ||= %r{\A#{Regexp.quote(request_path)}(/oidc_logout)}
      end

      def session_id_token
        key = "_pua_id_token"
        cookie = request.cookies[key]

        cookie = URI.unescape(cookie)
        data, iv, auth_tag = cookie.split("--").map do |v|
          Base64.strict_decode64(v)
        end
        cipher = OpenSSL::Cipher.new("aes-256-gcm")

        # Compute the encryption key
        secret_key_base = Rails.application.secret_key_base
        secret = OpenSSL::PKCS5.pbkdf2_hmac_sha1(secret_key_base, "authenticated encrypted cookie", 1000, cipher.key_len)

        # Setup cipher for decryption and add inputs
        cipher.decrypt
        cipher.key = secret
        cipher.iv  = iv
        cipher.auth_tag = auth_tag
        cipher.auth_data = ""

        # Perform decryption
        cookie_payload = cipher.update(data)
        cookie_payload << cipher.final
        cookie_payload = JSON.parse cookie_payload

        # Decode Base64 encoded stored data
        decoded_stored_value = Base64.decode64 cookie_payload["_rails"]["message"]
        stored_value = JSON.parse decoded_stored_value
      end

    end
  end
end
