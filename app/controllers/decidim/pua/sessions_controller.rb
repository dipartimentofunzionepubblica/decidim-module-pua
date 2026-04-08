# frozen_string_literal: true

module Decidim
  module Pua
    # Eredita dal controller delle sessioni standard di Decidim  
    class SessionsController < ::Devise::SessionsController
      include Decidim::DeviseControllers
      include Decidim::DeviseAuthenticationMethods

      def destroy
	    # 1. Memorizziamo se era un utente PUA prima di distruggere la sessione
	    was_pua_user = session["decidim-pua.signed_in"]
	    tenant_name = session["decidim-pua.tenant"]

	    # 2. Logout locale tramite Devise
	    # Usiamo il metodo standard che pulisce i cookie di sessione
	    signed_out = (::Devise.sign_out_all_scopes ? sign_out : sign_out(resource_name))
	  
	    # 3. IMPOSTIAMO IL MESSAGGIO DI SUCCESS
	    # set_flash_message! è il metodo interno di Devise
	    set_flash_message! :notice, :signed_out if signed_out

	    # 4. Logica di reindirizzamento
	    if was_pua_user && tenant_name
		  # Puliamo le chiavi custom (opzionale se sign_out ha già pulito tutto)
		  session.delete("decidim-pua.signed_in")
		  session.delete("decidim-pua.tenant")

		  tenant = Decidim::Pua.tenants.find { |t| t.name == tenant_name }
		
		# IMPORTANTE: Usiamo redirect_to verso la rotta OIDC logout che abbiamo sistemato.
		# Il flash message impostato sopra verrà portato dietro se il middleware lo consente,
		# altrimenti verrà rigenerato al ritorno dal provider.
		redirect_to send("user_#{tenant.name}_omniauth_oidc_logout_path")
	  else
		# Comportamento standard per utenti non-PUA
		respond_to_on_destroy
	  end
	end
      
    def oidc_logout
		# Recupera l'ultima posizione dell'utente (se salvata)
        stored_location = stored_location_for(resource_name)
			
        # Esegue l'effettivo sign_out locale da Rails/Devise
        # Se configurato, disconnette l'utente da tutti i "scopes" (es. admin e user)
        signed_out = (::Devise.sign_out_all_scopes ? sign_out : sign_out(resource_name))
		
        # Reindirizza l'utente alla home o alla posizione precedente		
        redirect_to stored_location || after_sign_out_path_for(resource_name)
	end

    end
  end
end
   