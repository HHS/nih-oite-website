class EventFilter
  class Option
    attr_reader :label, :value
    def initialize(label, value = nil)
      @label = label
      @value = value || label
    end
  end

  attr_reader :name, :label, :options

  def initialize(name, options)
    @name = name
    @options = options
  end
end
