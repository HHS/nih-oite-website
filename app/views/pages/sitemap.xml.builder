xml.instruct!
xml.urlset do
  xml.url do
    xml.loc root_url
    xml.lastmod overridden_last_modified_date
  end
  pages.each do |page|
    page_sitemap(page, xml)
  end
  Event.all(from: Date.today - 90).each do |event|
    xml.url do
      xml.loc event_url(event)
      xml.lastmod overridden_last_modified_date(event.updated_at)
    end
  end
end
