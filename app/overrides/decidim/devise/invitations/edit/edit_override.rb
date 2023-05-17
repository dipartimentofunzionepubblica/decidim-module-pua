# Copyright (C) 2023 Formez PA
# This program is free software: you can redistribute it and/or modify it under the terms of the GNU Affero General Public License as published by the Free Software Foundation, version 3.
# This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU Affero General Public License for more details.
# You should have received a copy of the GNU Affero General Public License along with this program. If not, see <https://www.gnu.org/licenses/>

# Forza gli utenti invitati a loggarsi tramite il PUA

Deface::Override.new(virtual_path: "decidim/devise/invitations/edit",
                     name: "add-pua-login",
                     replace_contents: "div.wrapper") do
  '
  <div class="row collapse">
    <div class="row collapse">
      <div class="columns large-8 large-centered text-center page-title">
        <h1><%= t "decidim.pua.devise.invitations.edit.header" %></h1>

        <p><%= t("decidim.pua.devise.invitations.edit.subtitle").html_safe %></p>
      </div>
    </div>

    <% size = current_organization.enabled_omniauth_providers.dig(:pua, :button_size).to_sym %>
    <%- if current_organization.enabled_omniauth_providers.keys.include?(:pua) %>
      <div class="row">
        <div class="columns large-6 medium-10 medium-centered">
          <%= button_to decidim_pua.send("user_#{current_organization.enabled_omniauth_providers.dig(:pua, :tenant_name)}_omniauth_authorize_path"),
          class: "button button--social button--#{normalize_provider_name(:pua)}", form_class: "button--#{size}" do %>
              <%= t("devise.shared.links.sign_in_with_provider_pua") %>
          <% end %>
        </div>
      </div>
    <% end %>
  </div>
'
end