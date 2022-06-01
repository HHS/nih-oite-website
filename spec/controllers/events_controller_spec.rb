require "rails_helper"

RSpec.describe EventsController do
  before {
    allow(Rails).to receive(:root).and_return(file_fixture("_events").join("..").cleanpath)
    allow(Date).to receive(:today).and_return(Date.new(2022, 4, 4))
  }

  it "does not filter by default" do
    get :index
    expect(assigns(:selected_filters)).to eq({
      "location" => [],
      "open_to" => [],
      "required_for" => [],
      "topic" => [],
      "type" => []
    })
  end

  it "does not show events in the past" do
    get :index
    expect(assigns(:events)).not_to be_nil
    expect(assigns(:events)).not_to be_empty
    expect(assigns(:events)).to all satisfy { |ev|
      ev.date >= Date.new(2022, 4, 4)
    }
  end

  it "can be filtered by audience they're open to" do
    get :index, params: {open_to: ["Summer Interns"]}
    expect(assigns(:events)).not_to be_nil
    expect(assigns(:events)).not_to be_empty
    expect(assigns(:events)).to all satisfy { |ev|
      ev.open_to.include? "Summer Interns"
    }
  end

  it "can be filtered by audience they're required for" do
    get :index, params: {required_for: ["Summer Interns"]}
    expect(assigns(:events)).not_to be_nil
    expect(assigns(:events)).not_to be_empty
    expect(assigns(:events)).to all satisfy { |ev|
      ev.open_to.include? "Summer Interns"
    }
  end

  it "can be filtered by topic" do
    get :index, params: {topic: ["Graduate School"]}
    expect(assigns(:events)).not_to be_nil
    expect(assigns(:events)).not_to be_empty
    expect(assigns(:events)).to all satisfy { |ev|
      ev.topic.include? "Graduate School"
    }
  end

  it "picks up content from the /events page" do
    get :index
    expect(assigns(:page)).not_to be_nil
    expect(assigns(:page)).to have_attributes filename: Pathname.new("events")
  end

  it "allows moving in time" do
    get :index, params: {from: "2022-02-01"}
    expect(assigns(:events)).not_to be_nil
    expect(assigns(:events)).not_to be_nil
    expect(assigns(:events)).not_to be_empty
    expect(assigns(:events)).to satisfy { |events|
      events[0].date == Date.parse("2022-02-01")
    }
    expect(assigns(:from)).to eql(Date.parse("2022-02-01"))
  end
end
