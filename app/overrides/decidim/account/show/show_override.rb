# Copyright (C) 2023 Formez PA
# This program is free software: you can redistribute it and/or modify it under the terms of the GNU Affero General Public License as published by the Free Software Foundation, version 3.
# This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU Affero General Public License for more details.
# You should have received a copy of the GNU Affero General Public License along with this program. If not, see <https://www.gnu.org/licenses/>

# Una volta loggato con PUA viene disabilitata la possibiltò di cambiare password

Deface::Override.new(virtual_path: "decidim/account/show",
                     name: "remove-change-password-with-pua",
                     replace: "erb[silent]:contains('if current_organization.sign_in_enabled?')",
                     closing_selector: "erb[silent]:contains('end')" ) do
"
  <% if current_organization.sign_in_enabled? && !current_user.must_log_with_pua? %>
    <p>
      <a data-toggle='passwordChange' class='change-password'><%= t '.change_password' %></a>
    </p>
    <div id='passwordChange' class='toggle-show' data-toggler='.is-expanded'>
      <%= render partial: 'password_fields', locals: { form: f } %>
    </div>
  <% end %>
"
end

Deface::Override.new(virtual_path: "decidim/account/show",
                     name: "pua-email-conflict-warning",
                     insert_before: "erb[loud]:contains('decidim_form_for(@account')") do
  "
  <% if (pua_email = current_user.pua_email_conflict) %>
    <div id='pua-email-conflict' class='flash warning'>
      <div class='flash__message block leading-relaxed' style='flex: 1 1 auto; min-width: 0; white-space: normal; overflow-wrap: anywhere;'>
        <p><strong><%= t('decidim.pua.account.email_conflict.title') %></strong></p>
        <p><%= t('decidim.pua.account.email_conflict.body', pua_email: pua_email, email: current_user.email) %></p>
      </div>
    </div>
  <% end %>
  "
end

Deface::Override.new(virtual_path: "decidim/account/show",
                     name: "disable-email-when-is-a-pua-account",
                     replace: "erb:contains('f.email_field :email')") do
  "
  <%= f.email_field :email, readonly: session['decidim-pua.tenant'].present? %>
  "
end