# Copyright (C) 2023 Formez PA
# This program is free software: you can redistribute it and/or modify it under the terms of the GNU Affero General Public License as published by the Free Software Foundation, version 3.
# This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU Affero General Public License for more details.
# You should have received a copy of the GNU Affero General Public License along with this program. If not, see <https://www.gnu.org/licenses/>

# Aggiunge badge PUA agli utenti nel backoffice che hanno utilizzato queste autorizzazioni

Deface::Override.new(virtual_path: "decidim/admin/officializations/index",
                     name: "add-badge-pua",
                     insert_before: 'div.card-section tbody tr td erb[loud]:contains("translated_attribute(user.officialized_as)")') do
'
  <%= user.must_log_with_pua? ? pua_icon : "" %>
'
end