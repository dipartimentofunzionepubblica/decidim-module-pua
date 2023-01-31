# frozen_string_literal: true

module Decidim
  module Pua
    module AdminLog
      class IdentityPresenter < Decidim::Log::BasePresenter
        private

        # def diff_fields_mapping
        #   {
        #     name: :i18n,
        #     area_type_id: :identity_type
        #   }
        # end

        def action_string
          case action
          when "registration", "login", "logout"
            "decidim.admin_log.identity.#{action}"
          else
            super
          end
        end

        def i18n_labels_scope
          "activemodel.attributes.identity"
        end

        def resource_presenter
          @resource_presenter ||= Decidim::Pua::IdentityPresenter.new(action_log.resource, h, action_log.extra["resource"])
        end
      end
    end
  end
end