require "rails_helper"

RSpec.describe Menu, type: :model do
  before {
    allow(Rails).to receive(:root).and_return(file_fixture("_pages").join("..").cleanpath)
  }

  let(:pages) {
    Page.build_hierarchy(file_fixture("_pages"))
  }

  subject {
    described_class.load(
      file_fixture("_settings/navigation.yml").cleanpath,
      pages
    )
  }

  describe ".items" do
    it "finds all items" do
      expect(subject.items).to have_attributes(size: 3)
    end
    it "defaults text to page title" do
      expect(subject.items[0].text).to eql("Page One")
    end
    it "allows customizing text" do
      expect(subject.items[1].text).to eql("Custom text")
    end
    it "hides children by default" do
      expect(subject.items[0].children).to have_attributes(size: 0)
    end
    it "shows children if include_children is set" do
      expect(subject.items[2].children).to have_attributes(size: 1)
    end
  end
end
