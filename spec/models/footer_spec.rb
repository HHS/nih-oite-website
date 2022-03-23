require "rails_helper"

RSpec.describe Footer, type: :model do
  subject { described_class.load file_fixture("_settings/footer.yml").cleanpath }

  describe "#links" do
    it "reads urls correctly" do
      expect(subject.links.map { |l| l.url }).to eql([
        "/link-1",
        "/foo"
      ])
    end

    it "reads link text correctly" do
      expect(subject.links.map { |l| l.text }).to eql([
        "Link 1",
        "Link with surrounding whitespace"
      ])
    end

    it "caches itself" do
      first = subject.links
      second = subject.links
      expect(first).to equal(second)
    end
  end
end
