# frozen_string_literal: true

module Decidim
  module Pua
    # This is the engine that runs on the public interface of `Pua`.
    class AdminEngine < ::Rails::Engine
      isolate_namespace Decidim::Pua::Admin

      paths["db/migrate"] = nil
      paths["lib/tasks"] = nil

      routes do
        # Add admin engine routes here
        scope :pua do
          resources :exports, only: [:index]
        end
      end

      initializer "decidim_pua_admin.mount_routes", before: "decidim_admin.mount_routes" do
        Decidim::Admin::Engine.routes.append do
          mount Decidim::Pua::AdminEngine => "/"
        end
      end

      initializer "decidim_pua.view_helpers" do
        ActiveSupport.on_load(:action_controller_base) do
          helper Decidim::Pua::Admin::ApplicationHelper
        end
      end

      def load_seed
        nil
      end
    end
  end
end
