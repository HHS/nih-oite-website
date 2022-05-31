class Event
  include NetlifyContent

  def self.all(from: nil, filters: nil, base: Rails.root.join("_events"))
    from ||= Date.today

    events = super base: base, from: from

    events = events.select do |event|
      in_date_range = event.date >= from

      next false unless in_date_range

      filters.nil? || filters.keys.all? { |filter_name|
        filter_method = "filter_by_#{filter_name}"
        options = filters[filter_name]

        if respond_to? filter_method
          send filter_method, event, options
        else
          filter_by_field filter_name, event, options
        end
      }
    end

    events.sort_by(&:date)
  end

  def self.should_parse_content_file(file, from:)
    date = approximate_date_from_filename(file)
    # Month + day are potentially ambiguous in our file naming scheme, so we
    # limit ourselves to year-level resolution here.
    date.year >= from.year
  end

  def self.approximate_date_from_filename(filename)
    m = /^(\d{4})([0-9]{1,2})([0-9]{1,2})-/.match File.basename(filename)

    return nil if m.nil?

    year = m[1].to_i
    month = m[2].to_i
    day = m[3].to_i

    if month > 12 || day == 0
      s = month.to_s
      month = s[0].to_i
      day = "#{s[1]}#{day}".to_i
    end

    Date.new year, month, day
  end

  def self.audiences(file = Rails.root.join("_settings/event_audiences.yml"))
    data = YAML.safe_load File.read(file), fallback: {}
    data["event_audiences"] || []
  end

  def self.locations(file = Rails.root.join("_settings/event_locations.yml"))
    data = YAML.safe_load File.read(file), fallback: {}
    data["event_locations"] || []
  end

  def self.topics(file = Rails.root.join("_settings/event_topics.yml"))
    data = YAML.safe_load File.read(file), fallback: {}
    data["event_topics"] || []
  end

  def self.types(file = Rails.root.join("_settings/event_types.yml"))
    data = YAML.safe_load File.read(file), fallback: {}
    data["event_types"] || []
  end

  def self.find_by_path(path, base: Rails.root.join("_events"), try_index: false)
    super path, base: base, try_index: try_index
  end

  def self.filter_by_required_for(event, options)
    return true if options.length == 0
    return false unless event.required?
    filter_by_field "open_to", event, options
  end

  def self.filter_by_field(field, event, options)
    return true if options.length == 0

    value = event.send(field)

    if value.is_a?(Enumerable)
      # For multi-value fields, match if _all_ of the filter options match
      options.all? { |option|
        value.any? { |value| value == option.value }
      }
    else
      # For single-value fields, match if the field value is one of the
      # filters we're using
      options.any? { |option| option.value == value }
    end
  end

  attr_reader :filename
  has_field :title, :type, :location
  has_field :speakers, :open_to, :required_for, default: []
  has_field :accommodations, default: {}
  has_field :topic, default: []

  def initialize(path, base: nil)
    @filename = path.basename(".md")
    @parsed_file = FrontMatterParser::Parser.parse_file(path, loader: yaml_loader)
  end

  def to_param
    filename.to_s
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

  def accommodations_poc
    accommodations["name"]
  end

  def accommodations_email
    accommodations["email"]
  end

  def accommodations_phone
    accommodations["phone"]
  end

  def nih_only?
    open_to.include?("NIH-only")
  end

  def required?
    open_to.length > 0 && parsed_file["required"]
  end

  private

  def date_with_time(time)
    m = /^(\d+):(\d+)\s*(am|pm)$/i.match time

    hour = m[1].to_i
    minute = m[2].to_i
    ampm = m[3].downcase

    hour += 12 if ampm == "pm" && hour < 12

    Time.new(
      date.year,
      date.month,
      date.day,
      hour,
      minute
    )
  end
end
