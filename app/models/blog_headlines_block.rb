class BlogHeadlinesBlock
  attr_reader :headlines
  def initialize(post_count)
    @post_count = post_count.to_i
    @headlines = read_rss
  end

  def parse(template)
    ERB.new(template).result(binding)
  end

  private

  def read_rss
    response = Faraday.get(ENV["OITE_BLOG_FEED"])
    if response.success?
      feed = RSS::Parser.parse(response.body)
      feed.items.take(@post_count).map { |item| BlogPost.new(item) }
    else
      []
    end
  end

  class BlogPost
    attr_reader :title, :blurb, :url
    def initialize(rss_entry)
      @title = rss_entry.title
      @blurb = rss_entry.description.truncate(150, separator: /\s/)
      @url = rss_entry.link
    end
  end
end
