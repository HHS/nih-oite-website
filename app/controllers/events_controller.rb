class EventsController < ApplicationController
  include VideoEmbeddable

  def index
    @audiences = Event.audiences
    @topics = Event.topics

    @from = if params[:from]
      begin
        Date.parse params[:from]
      rescue Date::Error
        nil
      end
    end

    @events = Event.all from: @from

    if params[:audience] && params[:audience].size > 0
      @selected_audiences = params[:audience]
      @events = @events.select { |event|
        event.audience.size > 0 && @selected_audiences.any? { |audience|
          event.audience.include? audience
        }
      }
    else
      @selected_audiences = []
    end

    if params[:topic] && params[:topic].size > 0
      @selected_topics = params[:topic]
      @events = @events.select { |event|
        event.topic.size > 0 && @selected_topics.any? { |topic|
          event.topic.include? topic
        }
      }
    else
      @selected_topics = []
    end

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
  end
end
