# Copyright (C) 2023 Formez PA
# This program is free software: you can redistribute it and/or modify it under the terms of the GNU Affero General Public License as published by the Free Software Foundation, version 3.
# This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU Affero General Public License for more details.
# You should have received a copy of the GNU Affero General Public License along with this program. If not, see <https://www.gnu.org/licenses/>

# frozen_string_literal: true

module Decidim
    module Pua
      module Admin

      # Custom helpers, scoped to the pua engine.
      #
      module ApplicationHelper

        def pua_icon
          content_tag :span, class: 'pua-badge' do
            image_pack_tag 'media/images/pua-logo.png', alt: "PUA Icon"
          end
        end
      end
    end
  end
end
