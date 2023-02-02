# Copyright (C) 2023 Formez PA
# This program is free software: you can redistribute it and/or modify it under the terms of the GNU Affero General Public License as published by the Free Software Foundation, version 3.
# This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU Affero General Public License for more details.
# You should have received a copy of the GNU Affero General Public License along with this program. If not, see <https://www.gnu.org/licenses/>

# Override per aggiungere e gestire i filtri PUA nel backoffice

module Decidim
  module Admin
    module Officializations
      module FilterableOverrides

        extend ActiveSupport::Concern

        included do
          include Decidim::Admin::Filterable

          private

          def base_query
            c = collection
            pua_filter = to_boolean(ransack_params.delete(:pua_presence))
            unless pua_filter.nil?
              c = pua_filter ? c.where(id: pua_ids) : c.where.not(id: pua_ids)
            end

            c.distinct
          end

          def search_field_predicate
            :name_or_nickname_or_email_cont
          end

          def filters
            [:officialized_at_null, :pua_presence]
          end

          def to_boolean(str)
            return if str.nil?
            str == 'true'
          end

          def pua_ids
            Decidim::Identity.where(provider: Decidim::Pua.tenants.map(&:name)).pluck(:decidim_user_id)
          end

        end
      end
    end
  end
end