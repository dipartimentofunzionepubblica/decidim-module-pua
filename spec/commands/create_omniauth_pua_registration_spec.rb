# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Pua
    describe CreateOmniauthPuaRegistration do
      include_context "shared_context"

      let(:form) do
        OmniauthPuaRegistrationForm.from_params(params, { email: email} ).with_context(current_user: user)
      end

      let(:subject) { described_class.new(form) }

      before do
        allow(subject).to receive(:organization).and_return(current_organization)
      end

      context "when registration is invalid" do
        it "broadcasts invalid for invalid form" do
          expect { subject.call }.to broadcast :invalid
        end
      end

      context "when registration is valid" do
        it "broadcasts valid for valid form" do
          expect(user.identities.count).to eq(0)
          f = OmniauthPuaRegistrationForm.from_params(params.merge(nickname: "alice"), { email: email} ).with_context(current_user: user)
          current_subject = described_class.new(f, email)
          allow(current_subject).to receive(:organization).and_return(current_organization)
          expect { current_subject.call }.to broadcast :ok
          expect(user.identities.count).to eq(1)
        end
      end

      context "when login is valid" do
        it "broadcasts valid for valid login" do
          user = identity.user
          expect(user).to be_present
          expect(user.identities.count).to eq(1)
          expect { subject.call }.to broadcast :ok
          expect(user.reload).to be_present
          expect(user.identities.count).to eq(1)
        end
      end

    end
  end
end
