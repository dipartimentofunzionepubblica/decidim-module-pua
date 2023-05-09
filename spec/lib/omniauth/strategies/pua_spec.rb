# frozen_string_literal: true

require "spec_helper"
require "omniauth/strategies/pua"

RSpec::Matchers.define :fail_with do |message|
  match do |actual|
    actual.redirect? && actual.location == /\?.*message=#{message}/
  end
end

# Silence the OmniAuth logger
# OmniAuth.config.logger = Logger.new("/dev/null")

module OmniAuth
  module Strategies
    describe Pua, type: :strategy do
      include_context 'shared_context'

      include Rack::Test::Methods
      include OmniAuth::Test::StrategyTestCase

      let(:app) { -> _ { [200, {}, ['Hello world.']] } }
      let(:tenant) { Decidim::Pua.tenants.first }
      let(:strategy) { described_class.new app, omniauth_settings }
      let(:omniauth_settings) { tenant.omniauth_settings }

      describe '#options' do
        before(:each) { strategy.call!(env) }

        it "applies the local options" do
          assert_equal 'https', strategy.options.client_options.scheme
          assert_equal 443, strategy.options.client_options.port
          assert_equal '/authorize', strategy.options.client_options.authorization_endpoint
          assert_equal '/token', strategy.options.client_options.token_endpoint
        end
      end

      describe '#request_phase' do
        subject { strategy.request_phase }
        before(:each) {
          strategy.call!(env)
          stub_login
        }

        it 'should make a redirect' do
          expect(subject.first).to eq 302
        end

        it 'should redirect to the correct endpoint & params' do
          uri = URI(subject[1]['Location'])
          expect(uri.host).to eq "localhost"
          expect(uri.scheme).to eq "https"
          expect(uri.port).to eq 5001
          expect(uri.path).to eq "/connect/authorize"
          expect(CGI::parse(uri.query).dig("client_id")).to eq ["ruby"]
          expect(CGI::parse(uri.query).dig("redirect_uri")).to eq ["http://192.168.1.11:3000/users/auth/openid_connect/callback"]
          expect(CGI::parse(uri.query).dig("scope")).to eq ["openid profile email"]
        end
      end

      describe '#callback_phase' do
        let(:request) { double('Request', params: callback_params.stringify_keys, path_info: "http://192.168.1.11:3000/users/auth/openid_connect/callback", path: 'path') }

        let(:strategy) do
          described_class.new(app, omniauth_settings).tap do |s|
            allow(s).to receive(:request) { request }
          end
        end

        subject { strategy.callback_phase }
        before(:each) {
          strategy.call!(env)
          stub_login
        }

        context 'with a successful response' do
          describe 'the auth hash' do
            before(:each) { strategy.callback_phase }

            subject { env['omniauth.auth'] }

            it 'should contain the name' do
              expect(subject.info['name']).to eq "Alice Smith"
            end

            it 'should contain the first name' do
              expect(subject.info['first_name']).to eq "Alice"
            end

            it 'should contain the last name' do
              expect(subject.info['last_name']).to eq "Smith"
            end

            it 'should contain the email' do
              expect(subject.info['email']).to eq email
            end

            it 'should contain the auth code' do
              expect(subject.extra["raw_info"]["providername"]).to eq "POSTE"
            end

            it 'should contain the session state' do
              expect(subject.extra["raw_info"]["providersubject"]).to eq "testtest2"
            end
          end
        end

      end
    end

  end
end
