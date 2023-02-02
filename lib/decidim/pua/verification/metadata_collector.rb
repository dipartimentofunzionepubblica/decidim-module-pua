# Copyright (C) 2023 Formez PA
# This program is free software: you can redistribute it and/or modify it under the terms of the GNU Affero General Public License as published by the Free Software Foundation, version 3.
# This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU Affero General Public License for more details.
# You should have received a copy of the GNU Affero General Public License along with this program. If not, see <https://www.gnu.org/licenses/>

# frozen_string_literal: true

# Effettua la mappatura dei dati provenienti dal PUA

module Decidim
  module Pua
    module Verification
      class MetadataCollector

        def initialize(tenant, attributes)
          @tenant = tenant
          @attributes = attributes
        end

        def metadata
          return nil unless tenant.attributes.is_a?(Hash)
          return nil if tenant.attributes.blank?

          collect.delete_if { |_k, v| v.nil? }
        end

        protected

        attr_reader :tenant, :attributes

        def collect
          tenant.attributes.map do |key, defs|
            value = begin
                      case defs
                      when Hash
                        attributes.public_send(defs[:type], defs[:name])
                      when String
                        attributes.dig(defs.to_sym)
                      end
                    end

            [key, value]
          end.to_h
        end
      end
    end
  end
end