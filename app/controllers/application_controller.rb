class ApplicationController < ActionController::Base
  include Pundit::Authorization

  before_action :look_up_pages

  private

  def look_up_pages
    @pages = Page.build_hierarchy Rails.root.join "_pages"
  end
end
