require "rails_helper"

RSpec.describe Page, type: :model do
  it "builds a hierarchy" do
    h = Page.build_hierarchy(file_fixture("_pages").cleanpath)

    expect(h.length).to eql(2)

    expect(h[0].title).to eql("Page One")
    expect(h[1].title).to eql("Page Two")

    expect(h[0].children.length).to eql(1)
    expect(h[1].children.length).to eql(0)

    expect(h[0].children[0].title).to eql("Child One")
    expect(h[0].children[0].children[0].title).to eql("Child Two")
  end
end
