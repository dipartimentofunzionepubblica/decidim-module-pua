# frozen_string_literal: true

module Decidim
  module Pua
    class IdentityPresenter < Decidim::Log::ResourcePresenter
      private

      def present_resource_name
        resource && resource.provider
      end

    end
  end
end