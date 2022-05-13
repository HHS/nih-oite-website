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

  describe "#build_side_nav" do
    it "provides Training nav at training root" do
      current_page = Page.find_by_path "/training", hierarchy: pages
      actual = _format_nav(Menu.build_side_nav(pages, current_page))
      expect(actual).to eql([
        "training/postbac",
        "training/program-1",
        "training/program-2"
      ])
    end
    it "provides expanded Postbac nav at postbac root" do
      current_page = Page.find_by_path "/training/postbac", hierarchy: pages
      actual = _format_nav(Menu.build_side_nav(pages, current_page))
      expect(actual).to eql([
        "training/postbac",
        "  training/postbac/about",
        "  training/postbac/eligibility",
        "  training/postbac/selection",
        "  training/postbac/after-you-apply",
        "training/program-1",
        "training/program-2"
      ])
    end
    it "provides expanded Postbac nav at postbac about page" do
      current_page = Page.find_by_path "/training/postbac/about", hierarchy: pages
      actual = _format_nav(Menu.build_side_nav(pages, current_page))
      expect(actual).to eql([
        "training/postbac",
        "  training/postbac/about",
        "  training/postbac/eligibility",
        "  training/postbac/selection",
        "  training/postbac/after-you-apply",
        "training/program-1",
        "training/program-2"
      ])
    end
  end
end

# condenses a nav hierarchy into a 1-d string array so it's easier to examine
def _format_nav(nav, depth = 0, array = [])
  nav.each { |item|
    array.push "#{"  " * depth}#{item.filename}"
    _format_nav item.children, depth + 1, array
  }
  array
end
