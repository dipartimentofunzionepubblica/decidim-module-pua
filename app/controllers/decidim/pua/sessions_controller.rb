# Copyright (C) 2023 Formez PA
# This program is free software: you can redistribute it and/or modify it under the terms of the GNU Affero General Public License as published by the Free Software Foundation, version 3.
# This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU Affero General Public License for more details.
# You should have received a copy of the GNU Affero General Public License along with this program. If not, see <https://www.gnu.org/licenses/>

# Gestisce il logout PUa o standard

# frozen_string_literal: true

module Decidim
  module Pua
    class SessionsController < ::Decidim::Devise::SessionsController
      def destroy
        return super unless session.delete("decidim-pua.signed_in")

        tenant_name = session.delete("decidim-pua.tenant")
        tenant = Decidim::Pua.tenants.find { |t| t.name == tenant_name }
        raise "Unkown PUA tenant: #{tenant_name}" unless tenant

        sign_out_path = send("user_#{tenant.name}_omniauth_oidc_logout_path")

        redirect_to sign_out_path
      end

      def oidc_logout
        stored_location = stored_location_for(resource_name)
        signed_out = (::Devise.sign_out_all_scopes ? sign_out : sign_out(resource_name))
        redirect_to stored_location || after_sign_out_path_for(resource_name)
      end

    end
  end
end