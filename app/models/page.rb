class Page
  include NetlifyContent

  def self.find_by_path(path, base: Rails.root.join("_pages"), try_index: true)
    super path, base: base, try_index: try_index
  end

  # Recursively searches a page hierarchy for a particular slug.
  # Netlify slugs don't have leading or trailing '/' characters, and may
  # end in `/index`.
  def self.find_by_slug(slug, pages)
    filename = Pathname(slug.to_s.gsub(/\/index$/, ""))

    pages.each do |p|
      if p.filename == filename
        return p
      else
        child = find_by_slug slug, p.children
        return child unless child.nil?
      end
    end

    nil
  end

  # constructs a hierarchy of Page objects from the filesystem at <dir>.
  def self.build_hierarchy(dir = Rails.root.join("_pages"), parent_path = "", base: nil)
    dir = Pathname(dir)
    parent_path = Pathname(parent_path)
    base ||= dir

    children = []
    index_md = nil

    Dir.each_child(dir).sort.each do |f|
      full_path = dir.join(f)

      if File.directory? full_path
        c = build_hierarchy full_path, parent_path.join(f), base: base
        children.push(*c)
      elsif f == "index.md"
        index_md = f
      end
    end

    if index_md
      index = find_by_path parent_path.join(index_md), base: base, try_index: false
      index.children = children
      children.each { |child| child.parent = index }
      [index]
    else
      children
    end
  end

  def self.normalize_path(path)
    "/#{path.gsub(/^\/+/, "")}"
  end

  attr_reader :filename, :base
  attr_writer :children
  attr_accessor :parent
  has_field :expires_at, :title, :redirect_to
  has_field :sidebar, default: []
  has_field :order, default: 0

  def initialize(full_path, base:)
    @filename = if full_path.basename(".md").to_s == "index"
      full_path.dirname
    else
      full_path
    end.relative_path_from(base)

    @base = base
    @parsed_file = FrontMatterParser::Parser.parse_file(full_path, loader: yaml_loader)
  end

  def children
    @children ||= []
  end

  def has_children?
    children.length > 0
  end

  def public?
    parsed_file["public"]
  end

  def obsolete?
    redirect_page.present?
  end

  def redirect_page
    if redirect_to.present?
      @redirect_page ||= self.class.find_by_path(redirect_to, base: base, try_index: false).filename
    end
  end

  def expired?
    expires_at.present? && expires_at.past?
  end

  def has_sidebar?
    sidebar.present?
  end

  def sidebar_blocks
    sidebar.map { |b| ContentBlock.find_by_path(b["block"]) }
  end
end
