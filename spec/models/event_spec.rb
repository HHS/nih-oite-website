require "rails_helper"

RSpec.describe Event, type: :model do
  describe ".find_by_path" do
    let(:base) { file_fixture("_events").cleanpath }

    it "finds the event when given the directory path" do
      event = described_class.find_by_path("202257-training-event", base: base)
      expect(event.title).to eq "Training Event"
    end

    it "raises a NotFound error when the path can't be found" do
      expect {
        described_class.find_by_path("missing", base: base)
      }.to raise_error(NetlifyContent::NotFound)
    end
  end

  subject { described_class.new file_fixture("_events/202257-training-event.md").cleanpath }

  describe "#title" do
    it "returns the event title" do
      expect(subject.title).to eq "Training Event"
    end
  end

  describe "#date" do
    it "returns the event date" do
      expect(subject.date).to eq Date.new(2022, 5, 7)
    end
  end

  describe "#start_time" do
    it "returns the start time for the event" do
      expect(subject.start_time).to eq "9:30 am"
    end
  end

  describe "#end_time" do
    it "returns the end time for the event" do
      expect(subject.end_time).to eq "11:00 am"
    end
  end

  describe "#speaker_names" do
    it "returns a list of speaker names" do
      expect(subject.speaker_names).to eq ["Ryan Ahearn, Esq"]
    end

    context "no speakers given" do
      subject { described_class.new file_fixture("_events/202257-slim-event.md").cleanpath }

      it "returns an empty array" do
        expect(subject.speaker_names).to eq []
      end
    end
  end

  describe "#audiences" do
    it "returns a list of the intended audiences" do
      expect(subject.audiences).to eq ["Summer Interns", "Postbacs"]
    end

    context "no audience given" do
      subject { described_class.new file_fixture("_events/202257-slim-event.md").cleanpath }

      it "returns an empty array" do
        expect(subject.audiences).to eq []
      end
    end
  end

  describe "#rendered_content" do
    it "returns the kramdown-rendered content" do
      expect(subject.rendered_content).to eq <<~EOHTML
        <p>This is the <strong>formatted</strong> description of the training event.</p>
      EOHTML
    end
  end
end
