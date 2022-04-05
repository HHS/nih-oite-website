class Event
  include NetlifyContent

  def self.all(after: nil, base: Rails.root.join("_events"))
    after ||= Date.today

    events = super base: base

    events.select { |event| event.date >= after }.sort_by(&:date)
  end

  def self.audiences(file = Rails.root.join("_settings/audiences.yml"))
    data = YAML.safe_load File.read(file), fallback: {}
    data["audiences"] || []
  end

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

  def start
    date_with_time start_time
  end

  def end
    date_with_time end_time
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

  def date_with_time(time)
    m = /^(\d+):(\d+)\s*(am|pm)$/i.match time

    hour = m[1].to_i
    minute = m[2].to_i
    ampm = m[3].downcase

    hour += 12 if ampm == "pm"

    Time.new(
      date.year,
      date.month,
      date.day,
      hour,
      minute
    )
  end

  def speakers
    parsed_file["speakers"] || []
  end
end
