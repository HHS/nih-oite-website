module ApplicationHelper
  def pages
    @pages ||= Page.build_hierarchy Rails.root.join "_pages"
  end
end
