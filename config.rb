ignore 'fonts/574515/*'

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
  deploy.deploy_method = :rsync
  deploy.host = '46.101.150.172'
  deploy.path = '/var/www/blog'
  deploy.user = 'deploy'
  deploy.flags = "-avz -e 'ssh -i ~/.ssh/digitalocean'"
  deploy.clean = true
  deploy.build_before = true
end

activate :directory_indexes
activate :autoprefixer

helpers do
  def metadata_for_article(article)
    "<time>Published #{article.date.strftime('%B %e, %Y')}</time>"
  end

  def markup_for_tag(tag)
    unless tag.nil?
      "<li class='tag'><a href='#{tag_path(tag)}'>#{tag.upcase}</a></li>"
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

# Font Management

after_build do |builder|
  src = File.join(config[:source],"fonts")
  dst = File.join(config[:build_dir],"fonts")
  builder.thor.source_paths << File.dirname(__FILE__)
  builder.thor.directory(src, dst)
end
