require "rails_helper"

RSpec.describe "Custom Kramdown Parser" do
  describe "Video Embeds" do
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

  describe "Content Blocks" do
    let(:element) {
      doc = Kramdown::Document.new(
        "
# Test

{::content_block slug=\"hours-location/block\" /}
          ".strip,
        input: "CustomParser"
      )
      doc.root.children.find { |e| e.type == :html_element }
    }

    let(:not_found_element) {
      doc = Kramdown::Document.new(
        "
# Test

{::content_block slug=\"block-that-does-not/exist\" /}
            ".strip,
        input: "CustomParser"
      )
      doc.root.children.find { |e| e.type == :comment }
    }

    it "embeds a known content block" do
      expect(element).to be_truthy
      expect(element.value).to eql("div")
      expect(element.attr["class"]).to eql("content-block content-block--hours-location")
    end

    it "inserts a comment when content block not found" do
      expect(not_found_element).to be_truthy
      expect(not_found_element.value).to eql("Content block not found: block-that-does-not/exist")
    end
  end

  describe "Unknown extensions" do
    let(:element) {
      doc = Kramdown::Document.new(
        "
# Test

{::unknown_tag attr=\"value\" /}
          ".strip,
        input: "CustomParser"
      )

      doc.root.children.find { |el| el.type == :p }
    }

    it "leaves unknown Kramdown extensions in the text" do
      expect(element).to be_truthy
      expect(element.children[0].type).to eql(:text)
      expect(element.children[0].value).to start_with("{::unknown_tag attr=")
    end
  end
end
