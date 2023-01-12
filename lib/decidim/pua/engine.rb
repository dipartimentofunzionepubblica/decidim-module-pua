# frozen_string_literal: true

require "rails"
require "decidim/core"

module Decidim
  module Pua
    # This is the engine that runs on the public interface of pua.
    class Engine < ::Rails::Engine
      isolate_namespace Decidim::Pua

      routes do
        # Add engine routes here
        # resources :pua
        # root to: "pua#index"
      end

      initializer "Pua.webpacker.assets_path" do
        Decidim.register_assets_path File.expand_path("app/packs", root)
      end
    end
  end
end
