class Page
  def self.find_by_path(path)
    new FrontMatterParser::Parser.parse_file(Rails.root.join("_pages", "#{path}.md"))
  end

  attr_reader :parsed_file
  def initialize(file)
    @parsed_file = file
  end

  def title
    parsed_file["title"]
  end

  def rendered_content
    Kramdown::Document.new(parsed_file.content).to_html.html_safe
  end
end
