xml.instruct!
xml.feed "xmlns" => "http://www.w3.org/2005/Atom" do
  xml.title "Sam Symons"
  xml.id "http://samsymons.com/"
  xml.link "href" => "http://samsymons.com/"
  xml.link "href" => "http://samsymons.com/feed.xml", "rel" => "self"
  xml.updated blog.articles.first.date.to_time.iso8601
  xml.author { xml.name "Sam Symons" }

  blog.articles[0..10].each do |article|
    xml.entry do
      xml.title article.title
      xml.link "rel" => "alternate", "href" => article.url
      xml.id article.url
      xml.published article.date.to_time.iso8601
      xml.updated article.date.to_time.iso8601
      xml.author { xml.name "Sam Symons" }
      xml.content article.body, "type" => "html"
    end
  end
end
