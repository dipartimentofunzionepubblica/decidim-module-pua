# frozen_string_literal: true

require "decidim/dev"
require "webmock"
require "utils/runtime"

ENV["ENGINE_ROOT"] = File.dirname(__dir__)

Decidim::Dev.dummy_app_path = File.expand_path(File.join(".", "spec", "decidim_dummy_app"))

Decidim::Pua::Test::Runtime.initializer do
  Decidim::Pua.configure do |config|
    config.name = "openid_connect"
    config.uid_field = "nickname"
    config.attributes = {
      name: "given_name",
      surname: "family_name",
      fiscal_code: 'nickname',
      gender: 'gender',
      birthdate: 'birthdate',
      phone_number: 'phone_number',
      email: 'email',
      address: 'address',
      providername: 'providername',
      providersubject: 'providersubject'
    }
    config.export_exclude_attributes = [ :surname ]
    config.scope = %i[openid profile email]
    config.issuer = "https://localhost:5001"
    config.relying_party = "http://192.168.1.11:3000"
    config.app_id = "ruby"
    config.app_secret= "test"
  end
end
Decidim::Pua::Test::Runtime.load_app

require "decidim/dev/test/base_spec_helper"


RSpec.configure do |config|
  config.full_backtrace = true
  config.warnings = false
end

Shoulda::Matchers.configure do |config|
  config.integrate do |with|
    with.test_framework :rspec
    with.library :rails
  end
end

OmniAuth.config.test_mode = true

require 'helpers/webmock_helper'
require 'helpers/shared_context'