class PagesController < ApplicationController
  content_security_policy only: :netlify do |policy|
    policy.script_src :self, "'unsafe-eval'"
    policy.style_src :self, "'unsafe-inline'"
    policy.img_src :self, :data, :blob
    policy.connect_src :self, :blob
  end

  def home
    pages_dir = Rails.root.join("_pages")
    @pages = Dir[pages_dir.join("**", "*.md")].map { |f|
      Pathname.new(f).relative_path_from(pages_dir)
    }.map { |p| Page.find_by_path(p) }
  end

  def page
    @page = Page.find_by_path params[:path]
    if @page.obsolete?
      redirect_to content_page_path(path: @page.redirect_page)
      return
    end
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
