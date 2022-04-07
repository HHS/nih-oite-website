require_relative "extensions/video"

class Kramdown::Parser::CustomParser < Kramdown::Parser::Kramdown
  include CustomParserExtensions

  def handle_extension(name, opts, body, type, line = nil)
    handler = "handle_#{name}_extension"
    if respond_to? handler
      return send handler, opts, body, type, line
    end

    false
  end
end
