# Copyright (C) 2023 Formez PA
# This program is free software: you can redistribute it and/or modify it under the terms of the GNU Affero General Public License as published by the Free Software Foundation, version 3.
# This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU Affero General Public License for more details.
# You should have received a copy of the GNU Affero General Public License along with this program. If not, see <https://www.gnu.org/licenses/>

# Aggiunti instance method al model utente

module Decidim
  class User

    def must_log_with_pua?
      # todo: verificare se bisogna controllare anche spid o cie per chi ha già migrato
      identities.map(&:provider).include?(organization.enabled_omniauth_providers.dig(:pua, :tenant_name))
    end

    # per disabilatare il recupera password se in precedenza hai fatto l'accesso con PUA
    def send_reset_password_instructions
      errors.add(:email, :cant_recover_password_due_pua) unless !self.must_log_with_pua?
      super
    end

    def unauthenticated_message
      must_log_with_pua? ? :invalid_due_pua : :invalid
    end
  end
end