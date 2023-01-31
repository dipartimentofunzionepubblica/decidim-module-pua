# frozen_string_literal: true

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
                        attributes.single(defs)
                      end
                    end

            [key, value]
          end.to_h
        end
      end
    end
  end
end