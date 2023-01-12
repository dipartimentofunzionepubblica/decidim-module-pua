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
        # resources :pua do
        #   collection do
        #     resources :exports, only: [:create]
        #   end
        # end
        # root to: "pua#index"
      end

      def load_seed
        nil
      end
    end
  end
end
