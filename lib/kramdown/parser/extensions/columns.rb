module CustomParserExtensions
  # handles the {::column span="whatever"} tag
  def handle_column_extension(opts, body, type, line)
    wrapper = Kramdown::Element.new(
      :html_element,
      "div",
      {
        # NOTE: {::columns} is responsible for setting the spans here.
        class: "grid-col"
      },
      category: :block,
      content_model: :block,
      location: line
    )

    content_doc = Kramdown::Document.new(body, input: "CustomParser")

    content_doc.root.children.each { |el|
      wrapper.children << el
    }

    @tree.children << wrapper
  end

  # handles the {::columns} tag
  def handle_columns_extension(opts, body, type, line)
    wrapper = Kramdown::Element.new(
      :html_element,
      "div",
      {
        "class" => "grid-row grid-gap grid-row--cms-columns"
      },
      category: :block,
      content_model: :block,
      location: line
    )

    content_doc = Kramdown::Document.new(body, input: "CustomParser")

    spans = (opts["span"] || "").split(",").map(&:to_i)

    content_doc.root.children.each do |el|
      is_column = el.type == :html_element && el.value == "div" && el.attr[:class] == "grid-col"

      if is_column
        span = spans.shift
        el.attr[:class] = if span.nil?
          # No span set for this column
          "tablet:grid-col"
        else
          "tablet:grid-col-#{span}"
        end
      end

      wrapper.children << el
    end

    @tree.children << wrapper
    true
  end
end
