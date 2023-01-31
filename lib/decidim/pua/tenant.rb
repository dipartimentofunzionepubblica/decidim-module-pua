require 'decidim/pua/token_verifier'

module Decidim
  module Pua
    class Tenant
      include ActiveSupport::Configurable

      # Il nome che identificata il singolo Tenant. Default: pua
      config_accessor :name, instance_writer: false do
        "pua"
      end

      # Root URL per il server di autorizzazione
      config_accessor :issuer, instance_reader: false do
        ""
      end

      # Root URL del tenant (Relying party)
      config_accessor :relying_party, instance_reader: false do
        ""
      end

      # Field todo: completare commento
      config_accessor :uid_field, instance_reader: false do
        "sub"
      end

      # todo: completare commento
      config_accessor :scope, instance_reader: false do
        []
      end

      # Implicit o Code Flow
      config_accessor :flow, instance_reader: false do
        :code
      end

      # APP ID
      config_accessor :app_id, instance_reader: false do
        ""
      end

      # APP SECRET
      config_accessor :app_secret, instance_reader: false do
        ""
      end

      # Le chiavi che verranno salvate nell'autorizzazione
      config_accessor :attributes do
        {}
      end

      # I campi da escludere dall'export a causa della polocy GDPR.
      # Deve contenere un'array di chiavi presenti in metadata_attributes
      config_accessor :export_exclude_attributes do
        []
      end
      #
      # # Permette di customizzare il workflow di autorizzazione.
      config_accessor :workflow_configurator do
        lambda do |workflow|
          # Di default, la scadenza è impostata a 0 minuti e quindi non scadrà
          workflow.expires_in = 0.minutes
          workflow.renewable = false
        end
      end

      # Permette di customizzare parte del flusso di autenticazione (come
      # le validazioni) prima che l'utente venga autenticato.
      config_accessor :authenticator_class do
        Decidim::Pua::Authentication::Authenticator
      end

      # Permette di customizzare parte del i metadata collezionati dagli
      # attributi SAML.
      config_accessor :metadata_collector_class do
        Decidim::Pua::Verification::MetadataCollector
      end

      def initialize
        yield self
      end

      def name=(name)
        raise(InvalidTenantName, "Il nome del tenant PUA può contenere solo lettere o underscore.") unless name.match?(/^[a-z_]+$/)
        config.name = name
      end

      def authenticator_for(organization, oauth_hash)
        authenticator_class.new(self, organization, oauth_hash)
      end

      def metadata_collector_for(attributes)
        metadata_collector_class.new(self, attributes)
      end

      def omniauth_settings
        opts = {
          name: name,
          strategy_class: OmniAuth::Strategies::Pua,
          issuer: config.issuer,
          discovery: true,
          scope: config.scope,
          uid_field: config.uid_field,
          post_logout_redirect_uri: "#{config.relying_party}/users/auth/#{name}/logout",
          client_options: {
            port: 443,
            scheme: 'https',
            host: config.issuer,
            identifier: config.app_id,
            secret: config.app_secret,
            redirect_uri: "#{config.relying_party}/users/auth/#{name}/callback",
          }
        }
        if config.flow == :implicit
          opts.merge!(
            response_type: :id_token, # solo code or token supportati da omniauth_openid_connect 0.5.0
            response_mode: 'form_post', # one of: :query, :fragment, :form_post, :web_message (Implicit Flow working only with fragment and form_post, omniauth_openid_connect only with query and form_post)
          )
        elsif config.flow == :code
          opts.merge!(
            response_type: :code, # solo code or token supportati da omniauth_openid_connect 0.5.0
            pkce: true,
            nonce: proc { SecureRandom.hex(32) }
            )
        else
          raise(InvalidFlow, "Il flusso selezionato non è disponibile. Es: :code or :implicit")
        end
        opts
      end

      def setup!
        setup_routes!
        ::Devise.setup do |config|
          # config.omniauth(:openid_connect, omniauth_settings)
          config.omniauth(name.to_sym, omniauth_settings)
        end

        # Customizzazione in caso di fallimenti altrimenti verrebbe sollevata
        # l'eccezione ActionController::InvalidAuthenticityToken.
        devise_failure_app = OmniAuth.config.on_failure
        OmniAuth.config.request_validation_phase = Decidim::Pua::TokenVerifier.new
        OmniAuth.config.on_failure = proc do |env|
          if env["PATH_INFO"] && env["PATH_INFO"].match?(%r{^/users/auth/#{config.name}($|/.+)})
            env["devise.mapping"] = ::Devise.mappings[:user]
            Decidim::Pua::OmniauthCallbacksController.action(
              :failure
            ).call(env)
          else
            # Call the default for others.
            devise_failure_app.call(env)
          end
        end
      end

      def setup_routes!
        config = self.config
        Decidim::Pua::Engine.routes do
          devise_scope :user do
            match(
              "/users/auth/#{config.name}",
              to: "omniauth_callbacks#passthru",
              as: "user_#{config.name}_omniauth_authorize",
              via: [:get, :post]
            )

            match(
              "/users/auth/#{config.name}/callback",
              to: "omniauth_callbacks#pua",
              as: "user_#{config.name}_omniauth_callback",
              via: [:get, :post]
            )
            match(
              "/users/auth/#{config.name}/create",
              to: "omniauth_callbacks#create",
              as: "user_#{config.name}_omniauth_create",
              via: [:post, :put, :patch]
            )
            match(
              "/users/auth/#{config.name}/oidc_logout",
              to: "sessions#oidc_logout",
              as: "user_#{config.name}_omniauth_oidc_logout",
              via: [:get, :post]
            )

            match(
              "/users/auth/#{config.name}/logout",
              to: "sessions#oidc_logout",
              as: "user_#{config.name}_omniauth_logout",
              via: [:get, :post]
            )
          end
        end
      end
    end
  end
end
