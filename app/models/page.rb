class Page
  def self.find_by_path(path, try_index = true)
    dirname = path.dirname
    filename = path.basename(".md")
    full_path = Rails.root.join "_pages", dirname, "#{filename}.md"
    if File.exist?(full_path)
      new dirname, filename, FrontMatterParser::Parser.parse_file(full_path)
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

  def title
    parsed_file["title"]
  end

  def rendered_content
    Kramdown::Document.new(parsed_file.content).to_html.html_safe
  end

  class NotFound < StandardError; end
end
