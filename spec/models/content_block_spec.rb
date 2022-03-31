require "rails_helper"

RSpec.describe ContentBlock, type: :model do
  describe ".find_by_path" do
    let(:base) { file_fixture("_blocks").cleanpath }

    it "finds the content block when given the directory path" do
      block = described_class.find_by_path("hours-location/block", base: base)
      expect(block.name).to eq "Hours"
    end

    it "raises a NotFound error when the path can't be found" do
      expect {
        described_class.find_by_path("missing", base: base)
      }.to raise_error(NetlifyContent::NotFound)
    end
  end

  subject { described_class.new file_fixture("_blocks/hours-location/block.md").cleanpath }

  describe "#name" do
    it "returns the block name" do
      expect(subject.name).to eq "Hours"
    end
  end

  describe "#rendered_content" do
    it "returns the kramdown-rendered content" do
      expect(subject.rendered_content).to eq <<~EOHTML
        <p>This is a content block</p>
      EOHTML
    end
  end
end
