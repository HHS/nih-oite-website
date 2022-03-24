require "yaml"

module ApplicationHelper
  def pages
    @pages ||= Page.build_hierarchy Rails.root.join "_pages"
  end

  def footer
    @footer ||= Footer.load
  end

  def menu
    @menu ||= Menu.load(Rails.root.join("_settings", "navigation.yml"), pages)
  end
end
