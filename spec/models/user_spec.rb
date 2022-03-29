require "rails_helper"
require "ostruct"

RSpec.describe User, type: :model do
  describe ".from_omniauth" do
    let(:auth) { OpenStruct.new(provider: "sso", uid: "12345", info: OpenStruct.new(email: "email@example.com")) }

    context "No existing user" do
      it "creates a new User" do
        expect {
          described_class.from_omniauth(auth)
        }.to change(User, :count).from(0).to(1)
      end
    end

    context "User exists already" do
      let!(:existing) { User.create(provider: "sso", uid: "12345", email: "email@example.com") }
      it "finds the existing user" do
        actual = nil
        expect {
          actual = described_class.from_omniauth(auth)
        }.to_not(change(User, :count))
        expect(actual).to eq existing
      end
    end
  end

  describe "validations" do
    it { should validate_presence_of :provider }
    it { should validate_presence_of :uid }
  end

  describe "#admin?" do
    it "returns true when roles contains admin" do
      expect(subject).to_not be_admin
      subject.roles << "admin"
      expect(subject).to be_admin
    end
  end

  describe "#_role?" do
    subject { build_stubbed :user, :cms }

    it "returns true if the user has a role matching the method" do
      expect(subject.cms_role?).to be true
    end
  end
end
