# Copyright (C) 2023 Formez PA
# This program is free software: you can redistribute it and/or modify it under the terms of the GNU Affero General Public License as published by the Free Software Foundation, version 3.
# This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU Affero General Public License for more details.
# You should have received a copy of the GNU Affero General Public License along with this program. If not, see <https://www.gnu.org/licenses/>

# frozen_string_literal: true

require "rails"
require "decidim/core"

module Decidim
  module Pua
    class Engine < ::Rails::Engine
      isolate_namespace Decidim::Pua

      routes do
        devise_scope :user do
          match(
            "/users/sign_out",
            to: "sessions#destroy",
            as: "destroy_user_session",
            via: [:delete, :post]
          )
        end
      end

      initializer "decidim_pua.mount_routes", before: :add_routing_paths do
        Decidim::Core::Engine.routes.prepend do
          mount Decidim::Pua::Engine => "/"
        end
      end

      initializer "decidim_pua.webpacker.assets_path" do
        Decidim.register_assets_path File.expand_path("app/packs", root)
      end

      initializer "decidim_pua.setup", before: "devise.omniauth" do
        Decidim::Pua.setup!
      end

      overrides = "#{Decidim::Pua::Engine.root}/app/overrides"
      config.to_prepare do
        Rails.autoloaders.main.ignore(overrides)
        Dir.glob("#{overrides}/**/*_override.rb").each do |override|
          load override
        end
      end
    end
  end
end
