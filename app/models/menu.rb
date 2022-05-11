# A Menu is a view into a hierarchy of pages.
class Menu
  class Item
    include Comparable

    attr_reader :page, :text
    delegate :public?, to: :page
    delegate :order, to: :page
    delegate :filename, to: :page

    def initialize(page, text = nil, include_children = false)
      @page = page
      @text = text || page.title
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
      page_path = Page.normalize_path(page.is_a?(Page) ? page.filename.to_s : page.to_s)
      Page.normalize_path(filename.to_s) == page_path
    end

    # Does this menu item represent the given page or one of its ancestors?
    def is_for_page_or_ancestor?(page)
      until page.nil?
        return true if is_for_page?(page)
        page = page.parent
      end

      false
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

    side_nav_pages.map { |page| Item.new(page, nil, true) }
  end

  attr_reader :items

  def initialize(items)
    @items = items
  end
end
