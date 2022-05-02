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

  describe "#start" do
    it "returns the date combined with the start time for the event" do
      expect(subject.start).to eq Time.new(2022, 5, 7, 9, 30)
    end
    describe "12:00 PM edge case" do
      subject {
        described_class.new file_fixture("_events/202267-starts-at-noon.md").cleanpath
      }
      it "interpreted correctly" do
        expect(subject.start).to eq Time.new(2022, 6, 7, 12, 0)
      end
    end
  end

  describe "#end" do
    it "returns the date combined with the end time for the event" do
      expect(subject.end).to eq Time.new(2022, 5, 7, 11, 0)
    end
    describe "12:00 PM edge case" do
      subject {
        described_class.new file_fixture("_events/202267-ends-at-noon.md").cleanpath
      }
      it "interpreted correctly" do
        expect(subject.end).to eq Time.new(2022, 6, 7, 12, 0)
      end
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

  describe "#audience" do
    it "returns a list of the intended audience" do
      expect(subject.audience).to eq ["Summer Interns", "Postbacs"]
    end

    context "no audience given" do
      subject { described_class.new file_fixture("_events/202257-slim-event.md").cleanpath }

      it "returns an empty array" do
        expect(subject.audience).to eq []
      end
    end
  end

  describe "#accommodations" do
    it "returns the object of POC info" do
      expect(subject.accommodations).to eq({
        "name" => "Ryan Ahearn",
        "email" => "ryan.ahearn@gsa.gov"
      })
    end
  end

  describe "#rendered_content" do
    it "returns the kramdown-rendered content" do
      expect(subject.rendered_content).to eq <<~EOHTML
        <p>This is the <strong>formatted</strong> description of the training event.</p>
      EOHTML
    end
  end

  describe "#updated_at" do
    it "returns a Time" do
      expect(subject.updated_at).to be_an_instance_of(Time)
    end
  end

  describe "#approximate_date_from_filename" do
    tests = {
      "202221-feb-1.md" => "2022-02-01",
      "2022127-ambiguous.md" => "2022-12-7",
      "202311-jan-1.md" => "2023-01-01",
      "2022112-ambiguous.md" => "2022-11-02",
      "20220112-jan12.md" => "2022-01-12",
      "2023913-sep-13.md" => "2023-09-13",
      "20231018-oct-18.md" => "2023-10-18",
      "2023130-jan-30.md" => "2023-01-30",
      "2020110-jan-10.md" => "2020-01-10"
    }
    tests.each { |input, expected|
      it "interprets '#{input}' as '#{expected}'" do
        actual = Event.approximate_date_from_filename(Pathname.new(input))
        expect(actual).to eql(Date.parse(expected))
      end
    }
  end
end
