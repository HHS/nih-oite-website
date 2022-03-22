require "rails_helper"

RSpec.describe "Pages", type: :request do
  describe "GET /" do
    it "returns http success" do
      get "/"
      expect(response).to have_http_status(:success)
    end
  end

  context "_pages routes" do
    before {
      allow(Rails).to receive(:root).and_return(file_fixture("_pages").join("..").cleanpath)
    }

    describe "GET public page" do
      it "returns http success" do
        get "/page-one"
        expect(response).to have_http_status(:success)
      end
    end

    describe "GET private page" do
      context "guest user" do
        it "redirects to root_path" do
          get "/root-file"
          expect(response).to redirect_to(root_path)
        end
      end

      context "logged in user" do
        before { sign_in create(:user) }
        it "returns http success" do
          get "/root-file"
          expect(response).to have_http_status(:success)
        end
      end
    end

    describe "get obsolete path" do
      before { sign_in create(:user) }
      it "redirects to the new page" do
        get "/page-two"
        expect(response).to redirect_to("http://www.example.com/page-one")
      end
    end
  end

  describe "GET /admin/" do
    context "guest user" do
      it "redirects back to root_path" do
        get "/admin/"
        expect(response).to redirect_to(root_path)
      end
    end

    context "admin signed in" do
      let(:admin) { create :user, :admin }
      before { sign_in admin }
      it "renders the netlify index page" do
        get "/admin/"
        expect(response).to render_template(:netlify)
      end
    end
  end

  describe "GET /admin/config.yml" do
    it "renders the config page" do
      get "/admin/config.yml"
      expect(response).to render_template(:netlify_config)
    end
  end
end
