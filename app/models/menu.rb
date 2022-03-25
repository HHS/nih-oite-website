# A Menu is a view into a hierarchy of pages.
class Menu
  class Item
    attr_reader :page, :text
    delegate :public?, to: :page

    def initialize(page, text = nil, include_children = false)
      @page = page
      @text = text || page.title
      @include_children = include_children
    end

    def include_children?
      !!@include_children
    end

    def children
      @children ||= if include_children?
        page.children.map { |child| Menu::Item.new child }
      else
        []
      end
    end

    def has_children?
      include_children? && page.has_children?
    end

    def path
      page.filename
    end
  end

  def self.load(file, pages)
    data = YAML.safe_load File.read(file), fallback: {}
    items = (data["items"] || []).map { |i|
      page = Page.find_by_slug(i["page"], pages)
      if page
        Item.new(page, i["text"], i["include_children"])
      end
    }

    new items.compact
  end

  attr_reader :items

  def initialize(items)
    @items = items
  end
end
