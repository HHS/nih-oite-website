require "rails_helper"

RSpec.describe Page, type: :model do
  before {
    allow(Rails).to receive(:root).and_return(file_fixture("_pages").join("..").cleanpath)
  }

  describe ".find_by_path" do
    it "finds an index file when given the directory path" do
      page = described_class.find_by_path("page-one/child-one")
      expect(page.title).to eq "Child One"
      expect(page.filename).to eq Pathname.new("page-one/child-one")
    end

    it "raises a NotFound error when the path can't be found" do
      expect {
        described_class.find_by_path("missing")
      }.to raise_error(Page::NotFound)
    end
  end

  describe ".find_by_slug" do
    it "finds a root-level page" do
      pages = described_class.build_hierarchy(file_fixture("_pages").cleanpath)
      page = described_class.find_by_slug("page-one/index", pages)
      expect(page).not_to be(nil)
      expect(page.filename.to_s).to eq("page-one")
    end
    it "finds a child page" do
      pages = described_class.build_hierarchy(file_fixture("_pages").cleanpath)
      page = described_class.find_by_slug("page-one/child-one/index", pages)
      expect(page).not_to be(nil)
      expect(page.filename.to_s).to eq("page-one/child-one")
      expect(page.children.length).to eql(1)
    end
  end

  describe ".build_hierarchy" do
    it "builds a hierarchy" do
      h = described_class.build_hierarchy(file_fixture("_pages").cleanpath)

      expect(h.length).to eql(3)

      expect(h[0].title).to eql("Root File")
      expect(h[1].title).to eql("Page One")
      expect(h[2].title).to eql("Page Two")

      expect(h[1].children.length).to eql(1)
      expect(h[2].children.length).to eql(0)

      expect(h[1].children[0].title).to eql("Child One")
      expect(h[1].children[0].children[0].title).to eql("Child Two")
    end
  end

  subject { described_class.find_by_path "page-two/index.md", false }

  describe "#has_children?" do
    it "returns true when the children array has been filled" do
      expect(subject).to_not have_children
      subject.children = [described_class.new(Pathname.new("path"), Pathname.new("file"), nil)]
      expect(subject).to have_children
    end
  end

  describe "#public?" do
    let(:public_page) { described_class.find_by_path "page-one/index.md", false }

    it "returns true when the parsed metadata is true" do
      expect(subject).to_not be_public
      expect(public_page).to be_public
    end
  end

  describe "#obsolete?" do
    let(:no_redirect) { described_class.find_by_path "page-one/index.md", false }

    it "returns true when redirect_to metadata is set" do
      expect(subject).to be_obsolete
      expect(no_redirect).to_not be_obsolete
    end
  end

  describe "#redirect_page" do
    it "returns the filename of the redirected-to page" do
      expect(subject.redirect_page).to eq Pathname.new("page-one")
    end
  end

  describe "#expired?" do
    let(:blank_expired) { described_class.find_by_path "page-one/index.md", false }

    it "returns true when expired is set and in the past" do
      expect(subject).to be_expired
      expect(blank_expired).to_not be_expired
    end
  end

  describe "#expires_at" do
    it "returns the parsed expires_at Time" do
      expect(subject.expires_at).to eq Time.parse("2022-03-17T20:30:00.000Z")
    end
  end

  describe "#title" do
    it "returns the Page title" do
      expect(subject.title).to eq "Page Two"
    end
  end

  describe "#rendered_content" do
    it "returns the kramdown-rendered content" do
      expect(subject.rendered_content).to eq <<~EOHTML
        <p>This is page two</p>
      EOHTML
    end
  end
end
