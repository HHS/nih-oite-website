# frozen_string_literal: true

require "rails_helper"

RSpec.describe GitRequest, type: :model do
  let(:new_label) { "netlify-cms/draft" }
  let(:params) { {labels: [new_label]} }
  subject { described_class.new params }

  describe "#approve_publish?" do
    context "setting label to netlify-cms/pending_publish" do
      let(:new_label) { "netlify-cms/pending_publish" }

      it "returns true" do
        expect(subject.approve_publish?).to be true
      end
    end

    it "returns false for any other label" do
      expect(subject.approve_publish?).to be false
    end
  end
end
