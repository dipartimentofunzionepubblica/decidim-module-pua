# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Pua

    describe OmniauthCallbacksController, type: :request do
      include_context 'shared_context'

      before(:each) do
        host! current_organization.host
      end

      describe "GET pua" do
        it "render page to complete username due missing nickname" do
          make_login
          expect(response).to have_http_status(:ok)
          expect(response).to render_template("decidim/devise/omniauth_registrations/new")
          expect(flash[:alert]).to eq("Could not authenticate you from PUA because \"An error occurred while logging in.\".")
          visit_settings_account
          expect(response).to have_http_status(:found)
          expect(response).to redirect_to("#{hostname}users/sign_in")
        end

        it "login completed with identity already present" do
          identity
          make_login
          expect(response).to have_http_status(:found)
          expect(response).to redirect_to(hostname)
          expect(flash[:notice]).to eq("Successfully authenticated from PUA account.")
          visit_settings_account
          expect(response).to have_http_status(:ok)
        end
      end

      describe "POST create" do
        it "creates user and redirect to accept terms" do
          expect(User.find_by(email: email, organization: current_organization)).not_to be_present
          post_registration(nickname)
          expect(User.find_by(email: email, organization: current_organization)).to be_present
          expect(response).to have_http_status(:found)
          expect(response).to redirect_to(hostname)
          expect(flash[:notice]).to eq("Successfully authenticated from PUA account.")
          visit_settings_account
          expect(response).to have_http_status(:found)
          expect(response).to redirect_to("#{hostname}pages/terms-and-conditions")
        end

        it "doesn't create user due missing nickname" do
          expect(User.find_by(email: email, organization: current_organization)).not_to be_present
          post_registration
          expect(User.find_by(email: email, organization: current_organization)).not_to be_present
          expect(response).to have_http_status(:ok)
          expect(response).to render_template("decidim/devise/omniauth_registrations/new")
          expect(flash[:alert]).to eq("Could not authenticate you from PUA because \"An error occurred while logging in.\".")
          visit_settings_account
          expect(response).to have_http_status(:found)
          expect(response).to redirect_to("#{hostname}users/sign_in")
        end
      end

    end
  end
end