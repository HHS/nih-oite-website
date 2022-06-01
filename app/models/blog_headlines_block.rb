class BlogHeadlinesBlock
  OITE_BLOG_FEED = "https://oitecareersblog.od.nih.gov/feed/".freeze

  def initialize(post_count)
    @post_count = post_count.to_i
  end

  def headlines
    @headlines ||= read_rss
  end

  def parse(template)
    ERB.new(template).result(binding)
  end

  private

  def read_rss
    response = Faraday.get(OITE_BLOG_FEED)
    if response.success?
      feed = RSS::Parser.parse(response.body)
      feed.items.take(@post_count).map { |item| BlogPost.new(item) }
    else
      []
    end
  rescue => ex
    Rails.logger.error { "Error loading OITE Blog headlines: #{ex.message}" }
    []
  end

  class BlogPost
    attr_reader :title, :blurb, :url
    def initialize(rss_entry)
      @title = ERB::Util.html_escape_once rss_entry.title
      @blurb = ERB::Util.html_escape_once rss_entry.description.truncate(150, separator: /\s/)
      @url = ERB::Util.html_escape_once rss_entry.link
    end
  end
end
