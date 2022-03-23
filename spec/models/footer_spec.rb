require "rails_helper"

RSpec.describe Footer, type: :model do
  before {
    allow(Rails).to receive(:root).and_return(file_fixture("_settings").join("..").cleanpath)
  }

  describe "#links" do
    it "reads urls correctly" do
      footer = described_class.load file_fixture("_settings/footer.yml").cleanpath
      expect(footer.links.map { |l| l.url }).to eql([
        "/link-1",
        "/foo"
      ])
    end

    it "reads link text correctly" do
      footer = described_class.load file_fixture("_settings/footer.yml").cleanpath
      expect(footer.links.map { |l| l.text }).to eql([
        "Link 1",
        "Link with surrounding whitespace"
      ])
    end

    it "caches itself" do
      footer = described_class.load file_fixture("_settings/footer.yml").cleanpath
      first = footer.links
      second = footer.links
      expect(first).to equal(second)
    end
  end
end
