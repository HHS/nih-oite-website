module CustomParserExtensions
  def handle_content_block_extension(opts, body, type, line)
    block = begin
      ContentBlock.find_by_slug opts["slug"]
    rescue ContentBlock::NotFound
      nil
    end

    if block

      block_class = opts["slug"].parameterize.gsub(/-block$/, "")

      element = Kramdown::Element.new(
        :html_element,
        "div",
        {
          "class" => "content-block content-block--#{block_class}"
        },
        category: :block,
        location: line
      )
      element.children << block.content_document.root
    else
      # No block found
      element = Kramdown::Element.new(
        :comment,
        "Content block not found: #{opts["slug"]}"
      )
    end

    @tree.children << element
    true
  end
end
