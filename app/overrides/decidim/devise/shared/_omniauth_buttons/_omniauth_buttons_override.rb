# Copyright (C) 2023 Formez PA
# This program is free software: you can redistribute it and/or modify it under the terms of the GNU Affero General Public License as published by the Free Software Foundation, version 3.
# This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU Affero General Public License for more details.
# You should have received a copy of the GNU Affero General Public License along with this program. If not, see <https://www.gnu.org/licenses/>

# Aggiungo il button per il login con PUA

Deface::Override.new(virtual_path: "decidim/devise/shared/_omniauth_buttons",
                     name: "add-provider-button-oidc",
                     insert_after: "erb[silent]:contains('current_organization.enabled_omniauth_providers.keys.each do |provider|')") do
  '
    <%- if provider == :pua %>
      <% size = current_organization.enabled_omniauth_providers.dig(:pua, :button_size).presence || "m" %>
      <%= button_to decidim_pua.send("user_#{current_organization.enabled_omniauth_providers.dig(:pua, :tenant_name)}_omniauth_authorize_path"),
          class: "button button--social button--#{normalize_provider_name(provider)}", form_class: "button--#{size}" do %>
          <%= t("devise.shared.links.sign_in_with_provider_pua") %>
      <% end %>
      <% next %>
    <% end %>
'
end