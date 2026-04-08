# Copyright (C) 2023 Formez PA
# This program is free software: you can redistribute it and/or modify it under the terms of the GNU Affero General Public License as published by the Free Software Foundation, version 3.
# This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU Affero General Public License for more details.
# You should have received a copy of the GNU Affero General Public License along with this program. If not, see <https://www.gnu.org/licenses/>

# Personalizzazione della strategia omniauth per passare l'id_token in fase di logout

require 'omniauth/openid_connect'

module OmniAuth
  module Strategies
    class Pua < OpenIDConnect

      def encoded_post_logout_redirect_uri
		  return unless options.post_logout_redirect_uri
		  
		  params = { post_logout_redirect_uri: options.post_logout_redirect_uri }
		  
		  # Aggiungiamo l'id_token solo se effettivamente presente
		  token = session_id_token
		  params[:id_token_hint] = token if token.present?
		  
		  # Log per debug: verifica cosa stiamo inviando al DFP
		  Rails.logger.debug "==============> LOGOUT PARAMS: #{params.inspect}"
		  
		  URI.encode_www_form(params)
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

	def session_id_token
	  # 1. Recuperiamo i cookie già decrittati da Rails se presenti nell'env di Rack
	  # Rails deposita il jar dei cookie qui durante il passaggio del middleware
	  if request.env['action_dispatch.cookies']
		id_token = request.env['action_dispatch.cookies'].signed_or_encrypted["_pua_id_token"]
		return id_token if id_token.present?
	  end

	  # 2. Fallback: Se il middleware non ha ancora popolato l'env, 
	  # carichiamo i cookie manualmente usando il key_generator di Rails
	  env = request.env
	  cookie_header = env['HTTP_COOKIE']
	  return nil if cookie_header.blank?

	  # Ricostruiamo il jar usando la configurazione dell'applicazione
	  req = ActionDispatch::Request.new(env)
	  id_token = req.cookie_jar.signed_or_encrypted["_pua_id_token"]

	  id_token
	rescue StandardError => e
	  # Usiamo un logger che non crasha se Rails non è inizializzato (anche se qui dovrebbe esserlo)
	  warn "==============> ERRORE RECUPERO ID TOKEN: #{e.message}"
	  nil
	end
	
    end
  end
end
