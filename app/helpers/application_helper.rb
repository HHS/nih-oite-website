require "yaml"

module ApplicationHelper
  def pages
    @pages ||= Page.build_hierarchy Rails.root.join "_pages"
  end

  def footer
    @footer ||= Footer.load
  end
end
