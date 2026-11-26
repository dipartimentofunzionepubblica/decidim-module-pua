# Copyright (C) 2023 Formez PA
# This program is free software: you can redistribute it and/or modify it under the terms of the GNU Affero General Public License as published by the Free Software Foundation, version 3.
# This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU Affero General Public License for more details.
# You should have received a copy of the GNU Affero General Public License along with this program. If not, see <https://www.gnu.org/licenses/>

# Dalla 0.28 la form usa decidim.omniauth_registrations_path: il submit deve tornare al controller PUA

Deface::Override.new(virtual_path: "decidim/devise/omniauth_registrations/new",
                     name: "pua-omniauth-registration-form-url",
                     replace: "erb[loud]:contains('decidim.omniauth_registrations_path')") do
  '
<%= decidim_form_for(@form, namespace: "registration", as: resource_name, url: (controller.is_a?(Decidim::Pua::OmniauthCallbacksController) ? omniauth_registrations_path(resource_name) : decidim.omniauth_registrations_path(resource_name))) do |f| %>
'
end
