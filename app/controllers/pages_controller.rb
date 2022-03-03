class PagesController < ApplicationController
  def home
  end

  def page
    @page = Page.find_by_path params[:path]
  end

  def netlify
    render layout: false
  end
end
