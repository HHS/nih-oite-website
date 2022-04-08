require_relative "extensions/content_block"
require_relative "extensions/video"

class Kramdown::Parser::CustomParser < Kramdown::Parser::Kramdown
  include CustomParserExtensions

  # Add support for new types of Kramdown extensions by implementing a handler:
  #  def handle_tagname_extension(name, opts, body, type, line)

  def handle_extension(name, opts, body, type, line = nil)
    handler = "handle_#{name}_extension"
    if respond_to? handler
      return send handler, opts, body, type, line
    end

    false
  end
end
