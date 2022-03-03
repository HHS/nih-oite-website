class Page
  def self.find_by_path(path)
    path = Rails.root.join "_pages", "#{path}.md"
    if File.exist?(path)
      new FrontMatterParser::Parser.parse_file(path)
    else
      fail NotFound
    end
  end

  attr_reader :parsed_file
  def initialize(file)
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
