# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Pua

    describe SessionsController, type: :request do
      include_context 'shared_context'

      before(:each) do
        host! current_organization.host
      end

      describe "DELETE destroy" do
        it "render page to complete username due missing nickname" do
          identity
          make_login
          visit_settings_account
          expect(response).to have_http_status(:ok)
          make_logout
          visit_settings_account
          expect(response).to have_http_status(:found)
          expect(response).to redirect_to("#{hostname}users/sign_in")
        end
      end

    end
  end
end