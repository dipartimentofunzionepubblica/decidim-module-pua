require 'omniauth/openid_connect'

module OmniAuth
  module Strategies
    class Pua < OpenIDConnect

      # Per passare al provider id_token_hint che permette il redirect dopo il logout
      def encoded_post_logout_redirect_uri
        return unless options.post_logout_redirect_uri

        URI.encode_www_form(
          post_logout_redirect_uri: options.post_logout_redirect_uri,
          id_token_hint: session['decidim-pua.id_token']
        )
      end

      # Personalizzazione per storare l'id_token in sessione nel Code Flow
      def access_token
        return @access_token if @access_token

        token_request_params = {
          scope: (options.scope if options.send_scope_to_token_endpoint),
          client_auth_method: options.client_auth_method,
        }

        token_request_params[:code_verifier] = params['code_verifier'] || session.delete('omniauth.pkce.verifier') if options.pkce

        @access_token = client.access_token!(token_request_params)
        verify_id_token!(@access_token.id_token) if configured_response_type == 'code'
        session['decidim-pua.id_token'] = @access_token.id_token

        @access_token
      end

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

    end
  end
end
