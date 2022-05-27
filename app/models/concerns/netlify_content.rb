module NetlifyContent
  extend ActiveSupport::Concern

  class_methods do
    def all(base:, limit: nil, **args)
      filenames = Dir.glob("*.md", base: base)

      # Allow content types that may contain a large number of files to provide a shortcut
      # around reading and parsing _every_ one.
      if respond_to?(:should_parse_content_file)
        filenames = filenames.select do |filename|
          send(:should_parse_content_file, filename, **args)
        end
      end

      filenames.map do |file|
        full_path = base.join file
        new full_path, base: base
      end
    end

    def find_by_path(path, base:, try_index:)
      dirname = Pathname(path).dirname
      filename = Pathname(path).basename(".md")
      full_path = base.join dirname, "#{filename}.md"
      if File.exist?(full_path)
        new full_path, base: base
      elsif try_index
        find_by_path(dirname.join(filename, "index.md"), base: base, try_index: false)
      else
        Rails.logger.error "Failed to find NetlifyContent path: #{full_path}"
        fail NotFound
      end
    end

    def has_blocks(*names)
      names.each do |name|
        define_method name do
          blocks = parsed_file[name.to_s]
          (blocks || []).map do |block|
            ContentBlock.find_by_path(block["block"])
          end
        end
      end
    end

    def has_field(*fields, through: nil, default: nil)
      fields.each do |field_name|
        define_method field_name do
          container = parsed_file

          if through.present?
            container = parsed_file[through.to_s]
            return default unless container
          end

          field_name = field_name.to_s.sub "?", ""

          container[field_name] || default
        end
      end
    end
  end

  included do
    attr_reader :parsed_file
    has_field :updated_by, :updated_at
  end

  def yaml_loader
    FrontMatterParser::Loader::Yaml.new(allowlist_classes: [Time])
  end

  def content_document
    Kramdown::Document.new(parsed_file.content, input: "CustomParser")
  end

  def rendered_content
    content_document.to_html.html_safe
  end

  def rendered_content_excerpt(max_length = 255)
    excerpt_doc = content_document
    trim_excerpt max_length, excerpt_doc.root
    excerpt_doc.to_html.html_safe
  end

  def trim_excerpt(max_length, element, parent = nil, text_elements = [], length = 0, depth = 0)
    if element.type == :text
      if length >= max_length
        parent.children.delete element
      else
        text_elements.push element
        length += element.value.length
      end
    end

    had_children = element.children.length > 0

    element.children.each do |child|
      length = trim_excerpt max_length, child, element, text_elements, length, depth + 1
    end

    if !parent.nil? && had_children && element.children.length == 0
      # All the children were removed from this element
      parent.children.delete element
    end

    elements_to_delete = []

    if parent.nil? && length > max_length
      # We need to trim down our actual text
      text_elements.reverse_each do |el|
        # Find the _last_ position in this text where we could insert our ellipsis
        m = el.value.reverse.match(/\b/)
        if m.nil? || m.begin(0) == 0
          # We can't do anything with this one
          el.value = ""
          elements_to_delete.push(el)
        else
          pos = el.value.length - m.begin(0)
          el.value = el.value.slice(0, pos) + "..."
          break
        end
      end
    end

    if parent.nil?
      clean_up_elements element, elements_to_delete
    end

    length
  end

  def clean_up_elements(element, elements_to_delete)
    # Remove any of element's children that appear in elements_to_delete
    # If this results in element not having any children left, the element
    # should be marked to be removed itself

    had_children = element.children.length > 0

    element.children = element.children.select { |child|
      if elements_to_delete.include? child
        next false
      end

      clean_up_elements child, elements_to_delete
    }.to_a

    still_has_children = element.children.length > 0

    # Keep if we had children + still have them, or never had them
    !had_children || (had_children && still_has_children)
  end

  class NotFound < StandardError; end
end
