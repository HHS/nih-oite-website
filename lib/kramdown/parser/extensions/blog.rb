module CustomParserExtensions
  def handle_blogs_extension(opts, body, type, line)
    post_count = opts["count"] || 3
    content = BlogHeadlinesBlock.new(post_count).parse(body)

    @tree.children << Kramdown::Element.new(
      :raw,
      content,
      category: :block,
      location: line
    )
  end
end
