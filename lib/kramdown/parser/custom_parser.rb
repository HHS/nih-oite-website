# Custom Kramdown parser for
class Kramdown::Parser::CustomParser < Kramdown::Parser::Kramdown
  def handle_extension(name, opts, body, type, line = nil)
    case name
    when "video"
      if handle_video opts, line
        return true
      end
    end

    super
  end

  def handle_video(opts, line)
    [:build_youtube_embed, :build_error_embed].each do |build|
      element = send build, opts["url"], opts["alt"], line
      if element
        @tree.children << element
        return true
      end
    end

    false
  end

  def build_error_embed(url, alt, line)
    div = Element.new(
      :html_element,
      "div",
      {
        "class" => "video video--error"
      },
      category: :block,
      content_model: :raw,
      location: line
    )
    add_text "Invalid video URL: #{url}", div

    div
  end

  def build_youtube_embed(url, alt, line)
    embed_url = get_youtube_embed_url url

    return unless embed_url

    iframe = Element.new(
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

    wrapper = Element.new(
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

  def get_youtube_embed_url video_url
    parsed = begin
      URI.parse video_url
    rescue URI::InvalidURIError
      nil
    end

    if parsed && parsed.host == "www.youtube.com"
      params = CGI.parse parsed.query
      video_id = params["v"].shift

      if video_id
        return URI.join "https://www.youtube-nocookie.com/embed/", video_id
      end

    end

    nil
  end
end
