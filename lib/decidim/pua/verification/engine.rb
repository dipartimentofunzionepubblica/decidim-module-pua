# Copyright (C) 2023 Formez PA
# This program is free software: you can redistribute it and/or modify it under the terms of the GNU Affero General Public License as published by the Free Software Foundation, version 3.
# This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU Affero General Public License for more details.
# You should have received a copy of the GNU Affero General Public License along with this program. If not, see <https://www.gnu.org/licenses/>

# frozen_string_literal: true

module Decidim
  module Pua
    module Verification
      class Engine < ::Rails::Engine
        isolate_namespace Decidim::Pua::Verification

        paths["db/migrate"] = nil
        paths["lib/tasks"] = nil

        routes do
          resource :authorizations, only: [:new], as: :authorization

          root to: "authorizations#new"
        end

        initializer "decidim_pua.verification_workflow", after: :load_config_initializers do
          Decidim::Pua.tenants.each do |tenant|
            Decidim::Verifications.register_workflow("#{tenant.name}_identity".to_sym) do |workflow|
              workflow.engine = Decidim::Pua::Verification::Engine

              tenant.workflow_configurator.call(workflow)
            end
          end
        end

        def load_seed
          Decidim::Pua.tenants.each do |tenant|
            org = Decidim::Organization.first
            org.available_authorizations << "#{tenant.name}_identity".to_sym
            org.save!
          end
        end
      end
    end
  end
end