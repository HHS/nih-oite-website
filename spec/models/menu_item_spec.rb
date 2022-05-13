require "rails_helper"

RSpec.describe Menu::Item, type: :model do
  describe ".text" do
    it "defaults to page title" do
      page = double("Page")
      allow(page).to receive_messages(title: "My page", nav_title: nil)

      item = described_class.new(page)
      expect(item.text).to eql("My page")
    end

    it "supports custom nav title" do
      page = double("Page")
      allow(page).to receive_messages(title: "My page", nav_title: "Custom nav title")

      item = described_class.new(page)
      expect(item.text).to eql("Custom nav title")
    end
  end

  describe "#is_for_page?" do
    let(:parent_page) {
      parent_page = double("Parent")
      allow(parent_page).to receive_messages(title: "Parent page", filename: "/parent")
      parent_page
    }

    let(:page) {
      page = double("Page")
      allow(page).to receive_messages(title: "Page", filename: "/parent/page", parent: parent_page)
      page
    }

    let(:child_page) {
      child_page = double("Child")
      allow(child_page).to receive_messages(title: "Child page", filename: "/parent/page/child", parent: page)
      child_page
    }

    let(:unrelated_page) {
      unrelated_page = double("Unrelated page")
      allow(unrelated_page).to receive_messages(title: "Unrelated page", filename: "/unrelated/page")
      unrelated_page
    }

    subject {
      Menu::Item.new(page)
    }

    it "doesn't choke on nil" do
      expect(subject.is_for_page?(nil)).to be false
    end

    it "is for its page" do
      expect(subject.is_for_page?(page)).to be true
    end

    it "is not for a parent page" do
      expect(subject.is_for_page?(parent_page)).to be false
    end

    it "is not for a child page" do
      expect(subject.is_for_page?(child_page)).to be false
    end

    it "is not for an unrelated page" do
      expect(subject.is_for_page?(unrelated_page)).to be false
    end
  end

  describe "#is_for_page_or_ancestor?" do
    let(:parent_page) {
      parent_page = double("Parent")
      allow(parent_page).to receive_messages(title: "Parent page", filename: Pathname.new("/parent"), parent: nil)
      parent_page
    }

    let(:page) {
      page = double("Page")
      allow(page).to receive_messages(title: "Page", filename: Pathname.new("/parent/page"), parent: parent_page)
      page
    }

    let(:child_page) {
      child_page = double("Child")
      allow(child_page).to receive_messages(title: "Child page", filename: Pathname.new("/parent/page/child"), parent: page)
      child_page
    }

    let(:unrelated_page) {
      unrelated_page = double("Unrelated page")
      allow(unrelated_page).to receive_messages(title: "Unrelated page", filename: Pathname.new("/unrelated/page"), parent: nil)
      unrelated_page
    }

    subject {
      Menu::Item.new(page)
    }

    it "doesn't choke on nil" do
      expect(subject.is_for_page_or_ancestor?(nil)).to be false
    end

    it "is for its page" do
      expect(subject.is_for_page_or_ancestor?(page)).to be true
    end

    it "is for a parent page" do
      expect(subject.is_for_page_or_ancestor?(parent_page)).to be false
    end

    it "is not for a child page" do
      expect(subject.is_for_page_or_ancestor?(child_page)).to be true
    end

    it "is not for an unrelated page" do
      expect(subject.is_for_page_or_ancestor?(unrelated_page)).to be false
    end
  end

  describe "#is_for_page_or_descendant?" do
    let(:child_page) {
      child_page = double("Child")
      allow(child_page).to receive_messages(title: "Child page", filename: "/parent/page/child", children: [])
      child_page
    }

    let(:page) {
      page = double("Page")
      allow(page).to receive_messages(title: "Page", filename: "/parent/page", children: [child_page])
      page
    }

    let(:parent_page) {
      parent_page = double("Parent")
      allow(parent_page).to receive_messages(title: "Parent page", filename: "/parent", children: [page])
      parent_page
    }

    let(:unrelated_page) {
      unrelated_page = double("Unrelated page")
      allow(unrelated_page).to receive_messages(title: "Unrelated page", filename: "/unrelated/page", children: [])
      unrelated_page
    }

    subject {
      Menu::Item.new(page)
    }

    it "doesn't choke on nil" do
      expect(subject.is_for_page_or_descendant?(nil)).to be false
    end

    it "is for its page" do
      expect(subject.is_for_page_or_descendant?(page)).to be true
    end

    it "is for a parent page" do
      expect(subject.is_for_page_or_descendant?(parent_page)).to be true
    end

    it "is not for a child page" do
      expect(subject.is_for_page_or_descendant?(child_page)).to be false
    end

    it "is not for an unrelated page" do
      expect(subject.is_for_page_or_descendant?(unrelated_page)).to be false
    end
  end

  describe "<=>" do
    it "compares by order" do
      page_a = double("Page A")
      allow(page_a).to receive_messages(title: "Page A", nav_order: 20)

      page_b = double("Page B")
      allow(page_b).to receive_messages(title: "Page B", nav_order: 10)

      a = Menu::Item.new(page_a)
      b = Menu::Item.new(page_b)

      expect(a <=> b).to eql(1)
      expect(b <=> a).to eql(-1)
    end

    it "falls back to comparison by title" do
      page_a = double("Page A")
      allow(page_a).to receive_messages(title: "Page A", nav_order: nil)

      page_b = double("Page B")
      allow(page_b).to receive_messages(title: "Page B", nav_order: nil)

      a = Menu::Item.new(page_a, "Sort me second!")
      b = Menu::Item.new(page_b, "Sort me first!")

      expect(a <=> b).to eql(1)
      expect(b <=> a).to eql(-1)
    end

    it "falls further back to comparison by page title" do
      page_a = double("Page A")
      allow(page_a).to receive_messages(title: "Sort me second!", nav_order: nil, nav_title: nil)

      page_b = double("Page B")
      allow(page_b).to receive_messages(title: "Sort me first!", nav_order: nil, nav_title: nil)

      a = Menu::Item.new(page_a)
      b = Menu::Item.new(page_b)

      expect(a <=> b).to eql(1)
      expect(b <=> a).to eql(-1)
    end
  end
end
