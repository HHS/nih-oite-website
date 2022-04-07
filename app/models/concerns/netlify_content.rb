module NetlifyContent
  extend ActiveSupport::Concern

  class_methods do
    def all(base:)
      Dir.glob("*.md", base: base).map do |file|
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

    def find_by_slug(slug, base:)
      full_path = Pathname(base).join "#{slug}.md"
      if File.exist?(full_path)
        new full_path, base: base
      else
        Rails.logger.error "Failed to find NetlifyContent path: #{full_path}"
        fail NotFound
      end
    end

    def has_field(*fields, default: nil)
      fields.each do |field_name|
        define_method field_name do
          parsed_file[field_name.to_s] || default
        end
      end
    end
  end

  included do
    attr_reader :parsed_file
  end

  def content_document
    Kramdown::Document.new(parsed_file.content, input: "CustomParser")
  end

  def rendered_content
    content_document.to_html.html_safe
  end

  class NotFound < StandardError; end
end
