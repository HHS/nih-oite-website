require "rails_helper"

RSpec.describe "Events", type: :request do
  describe "GET /events" do
    it "returns http success" do
      get "/events"
      expect(response).to render_template :index
    end
  end

  describe "GET /events/:id" do
    before {
      allow(Rails).to receive(:root).and_return(file_fixture("_events").join("..").cleanpath)
    }
    it "returns http success" do
      get "/events/202257-training-event"
      expect(response).to render_template :show
    end
  end
end
