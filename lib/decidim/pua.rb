# frozen_string_literal: true

require 'deface'
require "omniauth/strategies/pua"
# require "omniauth/openid_connect" # TODO: valutare se sono necessarie la customizzazione della startegy

require "decidim/pua/admin"
require "decidim/pua/engine"
require "decidim/pua/admin_engine"
require "decidim/pua/component"
require "decidim/pua/authentication"
require "decidim/pua/verification"

module Decidim
  module Pua
    autoload :Tenant, "decidim/pua/tenant"

    class << self
      def tenants
        @tenants ||= []
      end

      def test!
        @test = true
      end

      def configure(&block)
        tenant = Decidim::Pua::Tenant.new(&block)
        tenants.each do |existing|
          if tenant.name == existing.name
            raise(
              TenantSameName,
              "Definisci il nome del Tenant. Il nome \"#{tenant.name}\" è già in uso."
            )
          end

          match = tenant.name =~ /^#{existing.name}/
          match ||= existing.name =~ /^#{tenant.name}/
          next unless match

        end

        tenants << tenant
      end

      def setup!
        raise "Il modulo PUA è già stato inizializzato!" if initialized?

        @initialized = true
        tenants.each(&:setup!)
      end

      def find_tenant(name)
        Decidim::Pua.tenants.select { |a| a.name == name}.try(:first)
      end

      private

      def initialized?
        @initialized
      end
    end

    class TenantSameName < StandardError; end

    class InvalidTenantName < StandardError; end

    class InvalidFlow < StandardError; end
  end
end
