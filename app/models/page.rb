class Page
  def self.find_by_path(path)
    full_path = Rails.root.join "_pages", "#{path}.md"
    if File.exist?(full_path)
      new path, FrontMatterParser::Parser.parse_file(full_path)
    else
      fail NotFound
    end
  end

  attr_reader :parsed_file, :filename
  def initialize(filename, file)
    @filename = filename
    @parsed_file = file
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
