class EventsController < ApplicationController
  include VideoEmbeddable

  def index
    @audiences = Event.audiences

    @selected_audiences = if params[:audience].nil? || params[:audience].size == 0
      @audiences
    else
      params[:audience]
    end

    @events = Event.all.select { |event|
      event.audience.empty? || @selected_audiences.any? { |el|
        event.audience.include? el
      }
    }

    @page = begin
      Page.find_by_path "events"
    rescue Page::NotFound
      nil
    end
  end

  def show
    @event = Event.find_by_path(params[:id])
  end
end
