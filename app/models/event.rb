class Event
  include NetlifyContent

  def self.find_by_path(path, base: Rails.root.join("_events"), try_index: false)
    super path, base: base, try_index: try_index
  end

  def initialize(path, base: nil)
    loader = FrontMatterParser::Loader::Yaml.new(allowlist_classes: [Time])
    @parsed_file = FrontMatterParser::Parser.parse_file(path, loader: loader)
  end

  def title
    parsed_file["title"]
  end

  def date
    @date ||= begin
      d = parsed_file["date"]
      Date.new(d["year"], d["month"], d["day"])
    end
  end

  def start_time
    parsed_file["start"].downcase
  end

  def end_time
    parsed_file["end"].downcase
  end

  def speaker_names
    speakers.map { |speaker| speaker["name"] }
  end

  def audiences
    parsed_file["audience"] || []
  end

  private

  def speakers
    parsed_file["speakers"] || []
  end
end
