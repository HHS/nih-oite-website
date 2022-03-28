class Page
  def self.find_by_path(path, try_index = true)
    dirname = Pathname(path).dirname
    filename = Pathname(path).basename(".md")
    full_path = Rails.root.join "_pages", dirname, "#{filename}.md"
    if File.exist?(full_path)
      loader = FrontMatterParser::Loader::Yaml.new(allowlist_classes: [Time])
      new dirname, filename, FrontMatterParser::Parser.parse_file(full_path, loader: loader)
    elsif try_index
      find_by_path(dirname.join(filename, "index.md"), false)
    else
      Rails.logger.error "Failed to find Page path: #{path}"
      fail NotFound
    end
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
  def self.build_hierarchy(dir, parent_path = "")
    dir = Pathname(dir)
    parent_path = Pathname(parent_path)

    children = []
    md_files = []
    index_md = nil

    Dir.each_child(dir) do |f|
      full_path = dir.join(f)

      if File.directory? full_path
        c = build_hierarchy full_path, parent_path.join(f)
        children.push(*c)
      elsif f == "index.md"
        index_md = f
      elsif f.ends_with? ".md"
        md_files.push(f)
      end
    end

    pages = md_files.map { |f| find_by_path parent_path.join(f), false }

    if index_md
      index = find_by_path parent_path.join(index_md), false
      index.children = children
      pages.push index
    else
      pages.push(*children)
    end
  end

  attr_reader :parsed_file, :filename
  attr_accessor :children

  def initialize(path, file, file_contents)
    @filename = if file.to_s == "index"
      path
    else
      path.join(file)
    end
    @parsed_file = file_contents
    @children = []
  end

  def has_children?
    @children.length > 0
  end

  def public?
    parsed_file["public"]
  end

  def obsolete?
    redirect_page.present?
  end

  def redirect_page
    if parsed_file["redirect_to"].present?
      @redirect_page ||= self.class.find_by_path(parsed_file["redirect_to"], false).filename
    end
  end

  def expired?
    expires_at.present? && expires_at.past?
  end

  def expires_at
    parsed_file["expires_at"]
  end

  def title
    parsed_file["title"]
  end

  def rendered_content
    Kramdown::Document.new(parsed_file.content, input: "CustomParser").to_html.html_safe
  end

  class NotFound < StandardError; end
end
