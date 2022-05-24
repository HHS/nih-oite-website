module CustomParserExtensions
  def handle_video_extension(opts, body, type, line)
    [:build_youtube_embed, :build_nih_videocast_embed, :build_video_error_embed].each do |build|
      element = send build, opts["url"], opts["alt"], line
      if element
        @tree.children << element
        return true
      end
    end

    false
  end

  def build_nih_videocast_embed(url, alt, line)
    embed_url = get_nih_videocast_embed_url url
    video_iframe(embed_url, alt, line) if embed_url
  end

  def build_video_error_embed(url, alt, line)
    div = Kramdown::Element.new(
      :html_element,
      "div",
      {
        "class" => "video video--error"
      },
      category: :block,
      content_model: :block,
      location: line
    )
    add_text "Invalid video URL: #{url}", div

    div
  end

  def build_youtube_embed(url, alt, line)
    embed_url = get_youtube_embed_url url

    video_iframe(embed_url, alt, line) if embed_url
  end

  def get_nih_videocast_embed_url(video_url)
    # NIH Videocast urls look like this:
    # https://videocast.nih.gov/watch=44332
    parsed = begin
      URI.parse video_url
    rescue URI::InvalidURIError
      nil
    end

    return unless parsed && parsed.host == "videocast.nih.gov"

    m = /^\/watch=(\d+)$/.match(parsed.path)

    "https://videocast.nih.gov/embed.asp?live=#{m[1]}" if m
  end

  def get_youtube_embed_url(video_url)
    parsed = begin
      URI.parse video_url
    rescue URI::InvalidURIError
      nil
    end
    if parsed && parsed.host == "www.youtube.com"
      params = CGI.parse parsed.query
      video_id = params["v"].shift

      if video_id
        URI.join "https://www.youtube-nocookie.com/embed/", video_id
      end
    end
  end

  def video_iframe(embed_url, alt, line)
    iframe = Kramdown::Element.new(
      :html_element,
      "iframe",
      {
        "width" => 560,
        "height" => 315,
        "src" => embed_url.to_s,
        "title" => alt,
        "frameborder" => 0,
        "allow" => "accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture",
        "allowfullscreen" => true
      }
    )

    wrapper = Kramdown::Element.new(
      :html_element,
      "div",
      {
        "class" => "video"
      },
      category: :block,
      content_model: :raw,
      location: line
    )

    wrapper.children << iframe

    wrapper
  end
end
