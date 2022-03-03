class PagesController < ApplicationController
  def home
    @pages = Dir[Rails.root.join("_pages", "**", "*.md")].map { |f| Pathname.new(f).basename(".md") }.map { |f| Page.find_by_path(f) }
  end

  def page
    @page = Page.find_by_path params[:path]
    if @page.public? || user_signed_in?
      render formats: :html
    else
      store_location_for(:user, "/#{params[:path]}")
      redirect_to root_path
    end
  rescue Page::NotFound
    raise ActionController::RoutingError.new("Not Found")
  end

  def netlify
    render layout: false
  end

  def netlify_config
    @repo = ENV["NETLIFY_REPO"]
    @target_branch = ENV["NETLIFY_BRANCH"]
    @base_url = ENV["NETLIFY_AUTH_HOST"]
  end
end
