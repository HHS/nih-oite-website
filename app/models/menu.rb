# A Menu is a view into a hierarchy of pages.
class Menu
  class Item
    include Comparable

    attr_reader :page
    delegate :filename, :public?, :normalized_path, to: :page

    def initialize(page, text = nil, include_children = false)
      @page = page
      @text = text
      @include_children = include_children
    end

    def <=>(other)
      if (order || 0) == (other.order || 0)
        text <=> other.text
      else
        order <=> other.order
      end
    end

    def include_children?
      !!@include_children
    end

    def is_for_page?(page)
      !page.nil? && page.normalized_path == normalized_path
    end

    def is_for_page_or_ancestor?(page)
      is_for_page?(page) || (!page.nil? && is_for_page_or_ancestor?(page.parent))
    end

    # Does this menu item represent the given page or one of its children, grandchildren, etc.?
    def is_for_page_or_descendant?(page)
      return false if page.nil?
      return true if is_for_page?(page)
      page.children.any? { |child| is_for_page_or_descendant?(child) }
    end

    def children
      @children ||= if include_children?
        page.children
          .map { |child| Menu::Item.new child }
          .sort
      else
        []
      end
    end

    def has_children?
      include_children? && page.has_children?
    end

    def order
      page.nav_order
    end

    def text
      @text || page.nav_title || page.title
    end
  end

  def self.load(file, pages)
    data = YAML.safe_load File.read(file), permitted_classes: [Time], fallback: {}
    items = (data["items"] || []).map { |i|
      begin
        page = Page.find_by_slug(i["page"], pages)
        Item.new(page, i["text"], i["include_children"])
      rescue Page::NotFound
        nil
      end
    }

    new items.compact
  end

  def self.build_side_nav(pages, current_page)
    return [] if current_page.nil?

    side_nav_pages = if current_page.parent.nil?
      # We are at one of the top-level pages in the navigation hierarchy
      # We'll use that as our navigation root.
      current_page.children
    elsif current_page.parent.parent.nil?
      # We're one level deep in the navigation hierarchy
      # We will use this page + our siblings
      current_page.parent.children
    else
      current_page.parent.parent.children
    end

    side_nav_items = side_nav_pages.map { |page|
      include_children = page.filename == current_page.filename || page.contains?(current_page)
      Item.new(page, nil, include_children)
    }

    # Don't show side nav when there's only one thing to show
    if side_nav_items.length == 1 && side_nav_items[0].children.length == 0
      []
    else
      side_nav_items
    end
  end

  attr_reader :items

  def initialize(items)
    @items = items
  end
end
