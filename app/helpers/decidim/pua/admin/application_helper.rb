# frozen_string_literal: true

module Decidim
    module Pua
      module Admin

      # Custom helpers, scoped to the pua engine.
      #
      module ApplicationHelper

        def cie_icon
          content_tag :span, class: 'cie-badge' do
            image_pack_tag 'media/images/Logo_CIE_ID.svg', alt: "CIE Icon"
          end
        end

        def spid_icon
          content_tag :span, class: 'spid-badge' do
            image_pack_tag 'media/images/spid-logo.svg', alt: "Spid Icon"
          end
        end

        def pua_icon
          "Missing image"
        end
      end
    end
  end
end
