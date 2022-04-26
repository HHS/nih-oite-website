xml.instruct!
xml.urlset do
  xml.url do
    xml.loc root_url
  end
  pages.each do |page|
    page_sitemap(page, xml)
  end
  Event.all.each do |event|
    xml.url do
      xml.loc event_url(event)
      xml.lastmod event.updated_at&.xmlschema
    end
  end
end
