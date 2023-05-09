# frozen_string_literal: true

require "spec_helper"
module Decidim
  module Pua
    describe OmniauthPuaRegistrationForm do
      include_context "shared_context"

      context "without a nickname should be invalid" do
        subject { described_class.from_params(params, { email: email }) }

        it { is_expected.not_to be_valid }
      end

      context "without a nickname should be invalid" do
        subject { described_class.from_params(params.merge(nickname: nickname), { email: email }) }

        it { is_expected.to be_valid }
      end

    end
  end
end