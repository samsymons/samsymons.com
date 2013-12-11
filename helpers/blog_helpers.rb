module BlogHelpers
  def page_title
    title = "Sam Symons"

    if current_page.data.title 
      title = current_page.data.title + " | Sam Symons"
    end

    title
  end
end
