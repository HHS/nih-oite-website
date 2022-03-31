require "rails_helper"

RSpec.describe "Proxies", type: :request do
  let(:headers) { {"Content-Type" => "application/json"} }
  let(:user) { create :user, :cms }
  let(:settings_url) { "#{ENV["GIT_GATEWAY_HOST"]}settings" }
  let(:get_trees_url) { "#{ENV["GIT_GATEWAY_HOST"]}github/git/trees/netlify-cms:_pages" }
  let(:label_url) { "#{ENV["GIT_GATEWAY_HOST"]}github/issues/33/labels" }
  let(:post_trees_url) { "#{ENV["GIT_GATEWAY_HOST"]}github/git/trees" }
  before do
    stub_request(:get, settings_url)
    stub_request(:get, get_trees_url)
    stub_request(:put, label_url)
    stub_request(:post, post_trees_url)
    sign_in user
  end

  describe "GET /.netlify/git/settings" do
    it "proxies the request" do
      get "/.netlify/git/settings"
      expect(a_request(:get, settings_url)).to have_been_made.once
    end
  end

  describe "GET git api call" do
    it "proxies the request" do
      get "/.netlify/git/github/git/trees/netlify-cms:_pages"
      expect(a_request(:get, get_trees_url)).to have_been_made.once
    end
  end

  describe "PUT labels" do
    context "cms user" do
      context "mark as ready for review" do
        it "proxies the request" do
          put "/.netlify/git/github/issues/33/labels", params: {labels: ["netlify-cms/pending_review"]}.to_json, headers: headers
          expect(a_request(:put, label_url)).to have_been_made.once
        end
      end

      context "mark as approved to publish" do
        it "renders an error message" do
          put "/.netlify/git/github/issues/33/labels", params: {labels: ["netlify-cms/pending_publish"]}.to_json, headers: headers
          expect(response).to have_http_status(:forbidden)
          expect(response.body).to eq({message: "Only administrators can approve posts for publishing"}.to_json)
          expect(a_request(:put, label_url)).to_not have_been_made
        end
      end
    end

    context "admin user" do
      let(:user) { create :user, :admin }
      it "proxies publish label requests" do
        put "/.netlify/git/github/issues/33/labels", params: {labels: ["netlify-cms/pending_publish"]}.to_json, headers: headers
        expect(a_request(:put, label_url)).to have_been_made.once
      end
    end
  end

  describe "POST trees" do
    let(:page_tree_params) { {tree: [{path: "_pages/my-page.md"}]}.to_json }
    let(:event_tree_params) { {tree: [{path: "_events/2022330-training.md"}]}.to_json }

    context "cms user" do
      context "update an item in the Page collection" do
        it "proxies the request" do
          post "/.netlify/git/github/git/trees", params: page_tree_params, headers: headers
          expect(a_request(:post, post_trees_url)).to have_been_made.once
        end
      end

      context "update an item in the Event collection" do
        it "renders an error message" do
          post "/.netlify/git/github/git/trees", params: event_tree_params, headers: headers
          expect(response).to have_http_status(:forbidden)
          expect(response.body).to eq({message: "You do not have the appropriate role to save this file"}.to_json)
          expect(a_request(:post, post_trees_url)).to_not have_been_made
        end
      end
    end

    context "events user" do
      let(:user) { create :user, :events }
      context "update an item in the Event collection" do
        it "proxies the request" do
          post "/.netlify/git/github/git/trees", params: event_tree_params, headers: headers
          expect(a_request(:post, post_trees_url)).to have_been_made.once
        end
      end
    end

    context "admin user" do
      let(:user) { create :user, :admin }
      context "update an item in the Event collection" do
        it "proxies the request" do
          post "/.netlify/git/github/git/trees", params: event_tree_params, headers: headers
          expect(a_request(:post, post_trees_url)).to have_been_made.once
        end
      end
    end
  end
end
