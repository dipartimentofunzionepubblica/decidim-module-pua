# Copyright (C) 2023 Formez PA
# This program is free software: you can redistribute it and/or modify it under the terms of the GNU Affero General Public License as published by the Free Software Foundation, version 3.
# This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU Affero General Public License for more details.
# You should have received a copy of the GNU Affero General Public License along with this program. If not, see <https://www.gnu.org/licenses/>

# Aggiunge nel pannello di amministrazione /system le URL generate da comunicare per l'accreditamento PUA

Deface::Override.new(virtual_path: "decidim/system/organizations/_omniauth_provider",
                     name: "add-openid-connect-urls",
                     insert_bottom: "div.card-section") do
  '
  <% if provider == :pua && (tenant = Decidim::Pua.tenants.find { |t| t.name == f.object.try(:omniauth_settings_pua_tenant_name) } ) %>
    <p class="help-text"><%= t("login_url", scope: "#{i18n_scope}.#{provider}", url: "#{decidim_pua.send("user_#{tenant.name}_omniauth_callback_url")}") %></p>
    <p class="help-text"><%= t("post_logout_url", scope: "#{i18n_scope}.#{provider}", url: "#{decidim_pua.send("user_#{tenant.name}_omniauth_logout_url")}") %></p>
  <% end %>
'
end