class EventsController < ApplicationController
  include VideoEmbeddable

  def index
    @event_filters = [
      EventFilter.new(
        "type",
        Event.types.map { |type| EventFilter::Option.new(type) }
      ),
      EventFilter.new(
        "open_to",
        Event.audiences.map { |audience| EventFilter::Option.new(audience) }
      ),
      EventFilter.new(
        "required_for",
        Event.audiences.map { |audience| EventFilter::Option.new(audience) }
      ),
      EventFilter.new(
        "topic",
        Event.topics.map { |topic| EventFilter::Option.new(topic) }
      ),
      EventFilter.new(
        "location",
        Event.locations.map { |location| EventFilter::Option.new(location) }
      )
    ]

    open_accordion_names = (params[:acc] || "").split(",")
    @open_accordions = open_accordion_names.zip(open_accordion_names.map { true }).to_h

    @from = if params[:from]
      begin
        Date.parse params[:from]
      rescue Date::Error
        nil
      end
    end

    @selected_filters = {}
    @event_filters.each do |filter|
      @selected_filters[filter.name] = (params[filter.name] || [])
        .map { |value|
          filter.options.find { |opt| opt.value == value }
        }
        .select { |option| !option.nil? }
    end

    @events = Event.all from: @from, filters: @selected_filters

    @page_size = 10
    @page_index = (params[:page] || 1).to_i
    @page_count = (@events.length / @page_size.to_f).ceil

    start_page = @page_index - 2
    end_page = @page_index + 2

    if start_page < 1
      end_page += 1 - start_page
      start_page = 1
    end

    if end_page > @page_count
      end_page = @page_count
    end

    @page_range = (start_page..end_page)

    start = (@page_index - 1) * @page_size
    @events = @events.slice(start, @page_size) || []

    @pages = Page.build_hierarchy
    @page = begin
      Page.find_by_path "events", hierarchy: @pages
    rescue Page::NotFound
      nil
    end

    if @page.present?
      @side_nav_items = Menu.build_side_nav @pages, @page
      @show_sidebar = @page.has_sidebar? || @side_nav_items.length > 0
    end

    @not_found = begin
      ContentBlock.find_by_path "no-events-found/block"
    rescue ContentBlock::NotFound
      nil
    end
  end

  def show
    @event = Event.find_by_path(params[:id])
    @page_title = "#{@event.title} | #{@event.date.strftime("%-m/%-d/%Y")}"
  rescue Event::NotFound
    raise ActionController::RoutingError.new("Not Found")
  end
end
