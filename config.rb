activate :blog do |blog|
  blog.layout = "article"
  blog.permalink = "blog/:title"

  blog.taglink = "tags/{tag}.html"
  blog.tag_template = "tag.html"

  blog.sources = "articles/:year-:month-:day-:title.html"

  blog.paginate = true
  blog.page_link = "page/:num"
  blog.per_page = 5
end

activate :deploy do |deploy|
  deploy.method = :rsync
  deploy.host = '45.55.57.243'
  deploy.path = '/var/www/blog'
  deploy.user = 'deploy'
  deploy.flags = "-avz -e 'ssh -i /Users/samsymons/.ssh/digitalocean'"
  deploy.clean = true
  deploy.build_before = true
end

activate :directory_indexes

helpers do
  def metadata_for_article(article)
    "<time>Published #{article.date.strftime('%B %e, %Y')}</time><span class='metadata-separator'>•</span><a class='permalink' title='Permalink' href='#{article.url}'>&infin;</a>"
  end

  def markup_for_tag(tag)
    unless tag.nil?
      "<li class='tag'><a href='#{tag_path(tag)}'>##{tag.upcase}</a></li>"
    end
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
