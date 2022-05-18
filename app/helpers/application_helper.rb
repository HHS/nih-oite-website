require "yaml"

module ApplicationHelper
  def page_title
    "#{@page_title || params[:controller].titleize} | NIH OITE"
  end

  def pages
    @pages ||= Page.build_hierarchy Rails.root.join "_pages"
  end

  def footer
    @footer ||= Footer.load
  end

  def menu
    @menu ||= Menu.load(Rails.root.join("_settings", "navigation.yml"), pages)
  end

  def page_sitemap(page, builder)
    unless page.obsolete? || !page.public?
      builder.url do
        builder.loc content_page_url(path: page.filename)
        builder.lastmod page.updated_at&.xmlschema
      end
    end
    page.children.each do |child|
      page_sitemap(child, builder)
    end
  end
end
