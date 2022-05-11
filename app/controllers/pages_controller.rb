class PagesController < ApplicationController
  include VideoEmbeddable

  content_security_policy only: :netlify do |policy|
    policy.script_src :self, "'unsafe-eval'"
    policy.style_src :self, "'unsafe-inline'"
    policy.img_src :self, :data, :blob
    policy.connect_src :self, :blob
  end

  def home
  end

  def page
    @pages = Page.build_hierarchy

    @page = Page.find_by_path params[:path], hierarchy: @pages

    if @page.obsolete?
      redirect_to content_page_path(path: @page.redirect_page)
      return
    end

    @side_nav_items = Menu.build_side_nav @pages, @page

    @show_sidebar = @page.has_sidebar? || @side_nav_items.length > 0

    if @page.public? || user_signed_in?
      render formats: :html
    else
      store_location_for(:user, "/#{params[:path]}")
      redirect_to root_path
    end
  rescue Page::NotFound
    raise ActionController::RoutingError.new("Not Found")
  end

  def sitemap
    render :sitemap, formats: :xml
  end

  def robots
    render :robots, formats: :text
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
    authorize :netlify
    @target_branch = ENV["NETLIFY_BRANCH"]
  rescue Pundit::NotAuthorizedError
    store_location_for(:user, "/admin/")
    redirect_to root_path
  end
end
