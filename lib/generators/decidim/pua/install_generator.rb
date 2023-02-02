# Copyright (C) 2023 Formez PA
# This program is free software: you can redistribute it and/or modify it under the terms of the GNU Affero General Public License as published by the Free Software Foundation, version 3.
# This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU Affero General Public License for more details.
# You should have received a copy of the GNU Affero General Public License along with this program. If not, see <https://www.gnu.org/licenses/>

# Installer: genera lista Idp, initializer per singolo Tenant con linee guida su come configurare la gem
require 'decidim/pua/secret_modifier'

module Decidim
  module Pua
    module Generators
      class InstallGenerator < Rails::Generators::Base
        source_root File.expand_path('templates', __dir__)

        desc "Crea un Decidim PUA Tenant"

        argument :tenant_name, type: :string
        argument :issuer, type: :string
        argument :relying_party, type: :string

        def copy_initializer
          if Decidim::Pua.tenants.map(&:name).include?(tenant_name)
            say_status(:conflict, "Esiste già un tenant con questo nome", :red)
            exit
          end
          say_status(:conflict, "Il nome del tenant PUA può contenere solo lettere o underscore.", :red) && exit unless tenant_name.match?(/^[a-z_]+$/)
          template "decidim-pua.rb", "config/initializers/decidim-pua-#{tenant_name}.rb"
        end

        def enable_authentication
          secrets_path = Rails.application.root.join("config", "secrets.yml")
          secrets = YAML.safe_load(File.read(secrets_path), [], [], true)

          if secrets.dig("default", "omniauth", "pua")
            say_status :identical, "config/secrets.yml", :blue
          else
            mod = SecretsModifier.new(secrets_path, tenant_name, :pua)
            final = mod.modify

            target_path = Rails.application.root.join("config", "secrets.yml")
            File.open(target_path, "w") { |f| f.puts final }

            say_status :insert, "config/secrets.yml", :green
          end
          say_status :skip, "Ricorda di modificare config/secrets.yml omniauth se le configurazioni di :default non sono incluse", :yellow
        end

        def locales
          template "pua.en.yml", "config/locales/pua-#{tenant_name}.en.yml"
          template "pua.it.yml", "config/locales/pua-#{tenant_name}.it.yml"
          say_status :skip, "Completa le traduzione con le lingue disponibili config/locales/pua-#{tenant_name}.en.yml", :yellow
        end

        def organizations
          say_status :skip, "Ricorda di associare le organizzazioni con il relativo tenant in amministrazione (/system)", :yellow
        end

      end

    end
  end
end