class EventsController < ApplicationController
  include VideoEmbeddable

  def index
    @audiences = Event.audiences
    @topics = Event.topics

    @events = Event.all

    if params[:audience] && params[:audience].size > 0
      @selected_audiences = params[:audience]
      @events = @events.select { |event| @selected_audiences.any? { |el| event.audience.include? el } }
    else
      @selected_audiences = []
    end

    if params[:topic] && params[:topic].size > 0
      @selected_topics = params[:topic]
      @events = @events.select { |event| @selected_topics.any? { |el| event.topic.include? el } }
    else
      @selected_topics = []
    end

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
