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
    excerpt_doc.to_html.strip.html_safe
  end

  class NotFound < StandardError; end

  private

  def trim_excerpt(max_length, element, text_elements = [])
    length = 0

    element.children = element.children.map { |child|
      if length >= max_length
        next nil
      end

      if child.type == :html_element
        # We can't really measure HTML elements, so keep them in.
        next child
      end

      if child.type == :text
        text_elements.push(child)

        if length + child.value.length < max_length
          # This element's text is short enough to be included
          length += child.value.length
          next child
        else
          # This text element pushes our length over the limit. Cut it off.
          child_max_length = max_length - length
          cut_pos = 0
          loop do
            match = child.value.match(/\b/, cut_pos + 1)
            break if match.nil? || match.end(0) >= child_max_length
            cut_pos = match.end(0)
          end

          length = max_length

          if cut_pos > 0
            child.value = child.value.slice(0, cut_pos).gsub(/([[:punct:]]|\s)*$/, "") + "…"
            next child
          elsif text_elements.length > 1
            prev_el = text_elements[-2]
            prev_el.value = prev_el.value.gsub(/([[:punct:]]|\s)*$/, "") + "…"
          end

          next nil
        end
      end

      had_children = child.children.length > 0

      length += trim_excerpt(max_length - length, child, text_elements)

      if had_children && child.children.length == 0
        # We removed all this element's children, so remove it
        next nil
      end

      child
    }.compact

    length
  end
end
