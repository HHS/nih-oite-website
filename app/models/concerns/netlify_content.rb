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

    def has_field(*fields, through: nil, default: nil)
      fields.each do |field_name|
        define_method field_name do
          container = parsed_file

          if through.present?
            container = parsed_file[through.to_s]
            return default unless container
          end

          container[field_name.to_s] || default
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

  class NotFound < StandardError; end
end
