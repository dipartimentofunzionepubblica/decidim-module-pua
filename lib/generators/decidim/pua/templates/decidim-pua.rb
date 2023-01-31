# frozen_string_literal: true

Decidim::Pua.configure do |config|
  # Definisce il nome del tenant. Solo lettere minuscole e underscores sono permessi.
  # Default: pua. Quando hai multipli tenant devi definire un nome univoco rispetto ai vari tenant.
  config.name = "<%= tenant_name %>"

  # Definisce l'URL dell'Identity Server:
  # config.issuer = "https://www.example.org"
  config.issuer ="<%= issuer %>"

  # Definisce l'URL del Relying Party:
  # config.relying_party = "https://www.mydomain.org"
  config.relying_party = "<%= relying_party %>"

  # Attribute to match user
  # config.uid_field = :email # Default value: sub

  # Definisce lo scope da utilizzare:
  # config.scope = [] # Default: [] Es: %i[openid profile email]

  # Definisce il flusso da utilizzare (Code Flow o Implicit Flow):
  # config.flow = [] # Default::flow - Options: :code or :implicit

  # Definisce l'app ID
  # config.app_id = "client_id"

  # Definisce l'app secret
  # config.app_secret= "secret"

  # Le chiavi che verranno salvate sul DB nell'autorizzazione
  # #todo: correggere match
  # config.attributes = {
  #   name: "name",
  #   surname: "familyName",
  #   fiscal_code: "fiscalNumber",
  #   gender: "gender",
  #   birthday: "dateOfBirth",
  #   birthplace: "placeOfBirth",
  #   company_name: "companyName",
  #   registered_office: "registeredOffice",
  #   iva_code: "ivaCode",
  #   id_card: "idCard",
  #   mobile_phone: "mobilePhone",
  #   email: "email",
  #   address: "address",
  #   digital_address: "digitalAddress"
  # }
  #
  # # I campi da escludere dall'export nei processi a causa della policy GDPR.
  # # Deve contenere un'array di chiavi presenti in metadata_attributes.
  # # Se l'array è vuoto saranno inseriti tutti quelli disponibili
  # config.export_exclude_attributes = [
  #   :name, :surname, :fiscal_code, :company_name, :registered_office, :email, :iva_code
  # ]
  #



end