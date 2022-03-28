class ContentBlock
  include NetlifyContent

  def self.find_by_path(path, base: Rails.root.join("_blocks"), try_index: false)
    super path, base: base, try_index: try_index
  end

  def initialize(path, base: nil)
    @parsed_file = FrontMatterParser::Parser.parse_file(path)
  end

  def name
    parsed_file["name"]
  end
end
