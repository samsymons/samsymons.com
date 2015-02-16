require 'redcarpet'

module BlogHelpers
  def page_title
    title = "Sam Symons"

    if current_page.data.title
      title = current_page.data.title + " | Sam Symons"
    end

    title
  end

  def formatted_title(title)
    markdown = Redcarpet::Markdown.new(Redcarpet::Render::HTML, autolink: true)
    rendered_title = markdown.render title
    Regexp.new('^<p>(.*)<\/p>$').match(rendered_title)[1]
  end
end
