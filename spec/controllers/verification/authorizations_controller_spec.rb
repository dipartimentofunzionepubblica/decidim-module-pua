# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Pua
    module Verification

      describe AuthorizationsController, type: :controller do
        include_context 'shared_context'
        routes { Decidim::Pua::Verification::Engine.routes }

        before do
          @request.host = host
          identity
          request.env["decidim.current_organization"] = user.organization
          sign_in user, scope: :user
        end

        describe "GET new" do
          it "render page to associate account with PUA" do
            get :new
            expect(response).to have_http_status(:found)
            expect(response).to redirect_to("#{hostname}#{tenant.name}_identity/")
          end
        end

      end
    end
  end
end