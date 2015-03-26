activate :blog do |blog|
  blog.layout = "article"
  blog.permalink = "blog/:title"

  blog.sources = "articles/:year-:month-:day-:title.html"

  blog.paginate = true
  blog.page_link = "page/:num"
  blog.per_page = 5
end

activate :deploy do |deploy|
  deploy.method = :git
  deploy.build_before = true
end

activate :directory_indexes

helpers do
  def metadata_for_article(article)
    "<time>Published #{article.date.strftime('%B %e, %Y')}</time><span class='metadata-separator'>•</span><a class='permalink' title='Permalink' href='#{article.url}'>&infin;</a>"
  end

  def navigation_link_to(title, path)
    if current_page.url == path
      link_to title, path, :class => 'active'
    else
      link_to title, path
    end
  end
end

set :markdown_engine, :redcarpet
set :markdown, :fenced_code_blocks => true, :smartypants => true

page "/feed.xml", :layout => false

activate :automatic_image_sizes

set :css_dir, 'stylesheets'
set :js_dir, 'javascripts'
set :images_dir, 'images'

configure :build do
  activate :minify_css
end
