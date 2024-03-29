# Copyright (C) 2023 Formez PA
# This program is free software: you can redistribute it and/or modify it under the terms of the GNU Affero General Public License as published by the Free Software Foundation, version 3.
# This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU Affero General Public License for more details.
# You should have received a copy of the GNU Affero General Public License along with this program. If not, see <https://www.gnu.org/licenses/>

# Viene forzato in fase di registrazione l'utente a conservare l'email proveniente da PUA
# Aggiunto campo per la gestione omniauth in caso di errori di validazioni

Deface::Override.new(virtual_path: "decidim/devise/omniauth_registrations/new",
                     name: "disable-email-field-pua",
                     replace: "erb:contains('f.email_field :email')") do
  '
<%= f.email_field :email, readonly: session["decidim-pua.tenant"].present? && f.object.email.present? %>
<%= f.hidden_field :raw_data %>
<%= f.hidden_field :invitation_token %>
'
end