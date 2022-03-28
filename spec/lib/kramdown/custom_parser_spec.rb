require "rails_helper"

RSpec.describe "Custom Kramdown Parser" do
  describe "YouTube" do
    let(:element) {
      doc = Kramdown::Document.new(
        "
# Test

{::video url=\"https://www.youtube.com/watch?v=SAK117AmzSE\" alt=\"This is the alt text\" /}
        ".strip,
        input: "CustomParser"
      )

      # doc.root.children.each { |c| puts c.inspect }
      doc.root.children.find { |e| e.type == :html_element }
    }

    let(:iframe) {
      element.children.first
    }

    it "puts iframe in a wrapper" do
      expect(element.value).to eql("div")
      expect(element.block?).to be_truthy
      expect(element.attr["class"]).to eql("video")

      expect(iframe.type).to eql(:html_element)
      expect(iframe.value).to eql("iframe")
    end

    it "includes alt text as iframe title" do
      expect(iframe.attr["title"]).to eql("This is the alt text")
    end

    it "embeds youtube using -nocookie domain" do
      expect(iframe.attr["src"]).to eql("https://www.youtube-nocookie.com/embed/SAK117AmzSE")
    end
  end

  describe "Other URLs" do
    let(:element) {
      doc = Kramdown::Document.new(
        "
  # Test

  {::video url=\"https://www.example.org/my-video.m4v\" /}
          ".strip,
        input: "CustomParser"
      )

      # doc.root.children.each { |c| puts c.inspect }
      doc.root.children.find { |e| e.type == :html_element }
    }

    it "outputs an error message" do
      expect(element.value).to eql("div")
      expect(element.attr["class"]).to eql("video video--error")
    end
  end
end
