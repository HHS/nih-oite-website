require "rails_helper"

RSpec.describe "Events", type: :request do
  describe "GET /events" do
    it "returns http success" do
      get "/events"
      expect(response).to render_template :index
    end
  end
end
