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

  attr_reader :parsed_file, :filename
  def initialize(path, file, file_contents)
    @filename = if file.to_s == "index"
      path
    else
      path.join(file)
    end
    @parsed_file = file_contents
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
    Kramdown::Document.new(parsed_file.content).to_html.html_safe
  end

  class NotFound < StandardError; end
end
