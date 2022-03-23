require "rails_helper"

RSpec.describe "Sessions", type: :request do
  let(:user) { create :user, :cms }

  describe "POST /.netlify/identity/token" do
    context "guest user" do
      it "returns an error message" do
        post "/.netlify/identity/token"
        expect(response).to have_http_status(:unauthorized)
        expect(response.body).to eq({message: "User must be logged in first"}.to_json)
      end
    end
    context "cms user" do
      before { sign_in user }
      it "returns a JWT token" do
        post "/.netlify/identity/token"
        expect(response).to have_http_status(:success)
        token, _header = JWT.decode(JSON.parse(response.body)["access_token"], Rails.application.credentials.jwt_secret)
        expect(token["email"]).to eq user.email
        expect(token["exp"]).to be_kind_of(Integer)
        expect(token["app_metadata"]["roles"]).to eq ["cms"]
      end
    end
  end

  describe "GET /.netlify/identity/user" do
    context "guest user" do
      it "returns an error message" do
        get "/.netlify/identity/user"
        expect(response).to have_http_status(:unauthorized)
        expect(response.body).to eq({message: "User must be logged in first"}.to_json)
      end
    end
    context "cms user" do
      before { sign_in user }
      it "returns the current user's details" do
        get "/.netlify/identity/user"
        expect(response).to have_http_status(:success)
        body = JSON.parse(response.body)
        expect(body["email"]).to eq user.email
      end
    end
  end
end
