class Page
  include NetlifyContent

  def self.find_by_path(path, base: Rails.root.join("_pages"), try_index: true, hierarchy: nil)
    if hierarchy.nil?
      # Preserve functionality inherited from NetlifyContent...
      return super path, base: base, try_index: try_index
    end

    # ...but also allow searching a pre-built hierarchy
    path = normalize_path path

    hierarchy.each do |page|
      return page if normalize_path(page.filename.to_s) == path
      child = find_by_path path, hierarchy: page.children
      return child unless child.nil?
    rescue NotFound
      nil
    end

    fail NotFound
  end

  # "slug" is how Netlify identifies an item in a collection.
  # It is the path to the item's .md file, relative to the collection root,
  # without the ".md" extension. If it ends in "/index", that bit is ignored.
  def self.find_by_slug(slug, hierarchy)
    path = "/#{slug.gsub(/\/index$/, "")}"
    find_by_path path, hierarchy: hierarchy
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
    "/#{path.to_s.gsub(/^\/+/, "")}"
  end

  attr_reader :filename, :base, :hero
  attr_writer :children
  attr_accessor :parent
  has_field :expires_at, :redirect_to, through: :lifecycle
  has_field :public?, through: :access, default: false
  has_field :title
  has_field :sidebar, default: []

  def initialize(full_path, base:)
    @filename = if full_path.basename(".md").to_s == "index"
      full_path.dirname
    else
      full_path
    end.relative_path_from(base)

    @base = base
    @parsed_file = FrontMatterParser::Parser.parse_file(full_path, loader: yaml_loader)

    @hero = Hero.new(@parsed_file["hero"]) if @parsed_file["hero"]
  end

  def children
    @children ||= []
  end

  def has_children?
    children.length > 0
  end

  def contains?(other_page)
    children.any? { |child| child.normalized_path == other_page.normalized_path || child.contains?(other_page) }
  end

  def normalized_path
    Page.normalize_path filename
  end

  def nav_order
    nav = parsed_file["nav"]
    return 0 if nav.nil?
    nav["order"] || 0
  end

  def nav_title
    nav = parsed_file["nav"]
    return nil if nav.nil?
    nav["title"]
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
