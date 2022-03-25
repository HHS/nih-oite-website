class ContentBlock
  def self.find_by_path(path, base: Rails.root.join("_blocks"))
    full_path = base.join "#{path}.md"
    if File.exist?(full_path)
      new full_path
    else
      Rails.logger.error "Failed to find ContentBlock path: #{full_path}"
      fail NotFound
    end
  end

  attr_reader :parsed_file
  def initialize(path)
    @parsed_file = FrontMatterParser::Parser.parse_file(path)
  end

  def name
    parsed_file["name"]
  end

  def rendered_content
    Kramdown::Document.new(parsed_file.content).to_html.html_safe
  end

  class NotFound < StandardError; end
end
