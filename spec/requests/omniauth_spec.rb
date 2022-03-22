require "rails_helper"

RSpec.describe "Omniauth", type: :request do
  let(:uid) { "12345" }
  around do |example|
    OmniAuth.config.test_mode = true
    OmniAuth.config.mock_auth[:github] = OmniAuth::AuthHash.new({
      provider: "github",
      uid: uid,
      info: {email: "user@example.com"}
    })
    Rails.application.env_config["devise.mapping"] = Devise.mappings[:user]
    Rails.application.env_config["omniauth.auth"] = OmniAuth.config.mock_auth[:github]
    example.run
    OmniAuth.config.test_mode = false
    OmniAuth.config.mock_auth[:github] = nil
  end

  describe "POST /users/auth/github/callback" do
    it "creates a new user" do
      expect {
        post "/users/auth/github/callback"
      }.to change(User, :count).from(0).to 1
    end

    context "missing uid" do
      let(:uid) { nil }
      it "redirects the user back to the login page" do
        expect {
          post "/users/auth/github/callback"
        }.to_not change(User, :count)
        expect(response).to redirect_to(root_path)
      end
    end
  end
end
