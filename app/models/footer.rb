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

  def initialize(data)
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
    @links ||= build_links_array data["links"]
  end

  private

  def build_links_array(list)
    list = (list || []).map do |l|
      url = (l["url"] || "").strip
      text = (l["text"] || "").strip

      if url != "" && text != ""
        Footer::Link.new url, text
      end
    end

    list.select { |l| !l.nil? }
  end
end
