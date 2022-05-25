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

    @open_accordions = (params[:accordion] || {}).transform_values { |value| value == "true" }

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

    @limit = if params[:limit]
      params[:limit].to_i
    else
      25
    end

    @events = @events.slice(0, @limit)

    @page = begin
      Page.find_by_path "events"
    rescue Page::NotFound
      nil
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
