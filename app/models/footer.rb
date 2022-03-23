require "yaml"

# Model wrapping a blob of YAML data describing settings related to the global site footer.
class Footer
  class Link
    attr_reader :url, :text
    def initialize(url, text)
      @url = url
      @text = text
    end
  end

  attr_reader :data

  def self.load(file = Rails.root.join("_settings", "footer.yml"))
    data = YAML.safe_load File.read(file), fallback: {}
    new data
  end

  def initialize data
    @data = data
  end

  def agency_email
    @data["agency_email"]
  end

  def agency_name
    @data["agency_name"]
  end

  def agency_phone
    @data["agency_phone"]
  end

  def links
    unless @links
      @links = []
      (1..5).each do |i|
        l = @data["link#{i}"]
        next if l.nil?

        url = (l["url"] || "").strip
        text = (l["text"] || "").strip

        if url != "" && text != ""
          link = Footer::Link.new url, text
          @links.push link
        end
      end
    end
    @links
  end
end
