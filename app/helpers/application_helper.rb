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
        builder.lastmod overridden_last_modified_date(page.updated_at)
      end
    end
    page.children.each do |child|
      page_sitemap(child, builder)
    end
  end

  def overridden_last_modified_date(updated_at = nil)
    override = Time.parse(ENV["SITEMAP_LAST_MOD_OVERRIDE"]) if ENV["SITEMAP_LAST_MOD_OVERRIDE"].present?
    [override, updated_at].compact.max&.xmlschema
  end

  def uswds_icon(name, options = {})
    options = options.symbolize_keys
    options[:class] = "usa-icon #{options[:class]}"
    options[:aria] = {hidden: true}
    options[:focusable] = false
    options[:role] = "img"

    sprite_path = image_path("@uswds/uswds/dist/img/sprite.svg")

    content_tag "svg", options do
      tag "use", {"xlink:href": "#{sprite_path}##{name}"}
    end
  end
end
