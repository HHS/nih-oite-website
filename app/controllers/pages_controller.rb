class PagesController < ApplicationController
  content_security_policy only: :netlify do |policy|
    policy.script_src :self, "'unsafe-eval'"
    policy.style_src :self, "'unsafe-inline'"
  end

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
    if user_signed_in?
      render layout: false
    else
      store_location_for(:user, "/admin/")
      redirect_to root_path
    end
  end

  def netlify_config
    @target_branch = ENV["NETLIFY_BRANCH"]
  end
end
