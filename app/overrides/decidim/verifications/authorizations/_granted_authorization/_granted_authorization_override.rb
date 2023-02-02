# Copyright (C) 2023 Formez PA
# This program is free software: you can redistribute it and/or modify it under the terms of the GNU Affero General Public License as published by the Free Software Foundation, version 3.
# This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU Affero General Public License for more details.
# You should have received a copy of the GNU Affero General Public License along with this program. If not, see <https://www.gnu.org/licenses/>

# Aggiunge un valore di default alle autorizzazioni di default

Deface::Override.new(virtual_path: "decidim/verifications/authorizations/_granted_authorization",
                     name: "add-openid-default-values-to-authorization",
                     replace: "erb:contains('t(\"\#\{authorization.name\}.name\", scope: \"decidim.authorization_handlers\")')") do
  '
  <%= t("#{authorization.name}.name", scope: "decidim.authorization_handlers", default: t("decidim.authorization_handlers.identity.name") ) %>
'
end