require "rails_helper"

RSpec.describe "Proxies", type: :request do
  let(:user) { create :user, :cms }
  before do
    stub_request(:get, "#{ENV["GIT_GATEWAY_HOST"]}settings")
    stub_request(:get, "#{ENV["GIT_GATEWAY_HOST"]}github/git/trees/netlify-cms:_pages")
    stub_request(:put, "#{ENV["GIT_GATEWAY_HOST"]}github/issues/33/labels")
    sign_in user
  end

  describe "GET /.netlify/git/settings" do
    it "proxies the request" do
      get "/.netlify/git/settings"
      expect(a_request(:get, "#{ENV["GIT_GATEWAY_HOST"]}settings")).to have_been_made.once
    end
  end

  describe "GET git api call" do
    it "proxies the request" do
      get "/.netlify/git/github/git/trees/netlify-cms:_pages"
      expect(a_request(:get, "#{ENV["GIT_GATEWAY_HOST"]}github/git/trees/netlify-cms:_pages")).to have_been_made.once
    end
  end

  describe "PUT labels" do
    let(:headers) { {"Content-Type" => "application/json"} }

    context "cms user" do
      context "mark as ready for review" do
        it "proxies the request" do
          put "/.netlify/git/github/issues/33/labels", params: {labels: ["netlify-cms/pending_review"]}.to_json, headers: headers
          expect(a_request(:put, "#{ENV["GIT_GATEWAY_HOST"]}github/issues/33/labels")).to have_been_made.once
        end
      end

      context "mark as approved to publish" do
        it "renders an error message" do
          put "/.netlify/git/github/issues/33/labels", params: {labels: ["netlify-cms/pending_publish"]}.to_json, headers: headers
          expect(response).to have_http_status(:forbidden)
          expect(response.body).to eq({message: "Only administrators can approve posts for publishing"}.to_json)
          expect(a_request(:put, "#{ENV["GIT_GATEWAY_HOST"]}github/issues/33/labels")).to_not have_been_made
        end
      end
    end

    context "admin user" do
      let(:user) { create :user, :admin }
      it "proxies publish label requests" do
        put "/.netlify/git/github/issues/33/labels", params: {labels: ["netlify-cms/pending_publish"]}.to_json, headers: headers
        expect(a_request(:put, "#{ENV["GIT_GATEWAY_HOST"]}github/issues/33/labels")).to have_been_made.once
      end
    end
  end
end
