xml.instruct!
xml.feed "xmlns" => "http://www.w3.org/2005/Atom" do
  site_url = "http://samsymons.com/"

  xml.title "Sam Symons"
  xml.id site_url
  xml.link "href" => site_url
  xml.link "href" => "#{site_url}feed.xml", "rel" => "self"
  xml.updated blog.articles.first.date.to_time.iso8601
  xml.author { xml.name "Sam Symons" }

  blog.articles[0..10].each do |article|
    xml.entry do
      xml.title article.title
      xml.link "rel" => "alternate", "href" => URI.join(site_url, article.url)
      xml.id article.url
      xml.published article.date.to_time.iso8601
      xml.updated article.date.to_time.iso8601
      xml.author { xml.name "Sam Symons" }
      xml.content article.body, "type" => "html"
    end
  end
end
