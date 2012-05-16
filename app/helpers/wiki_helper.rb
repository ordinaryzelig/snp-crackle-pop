SnpCracklePop.helpers do

  # Render using markdown.
  # Specify that layout should use HAML for rendering.
  def wiki(page_name, options = {})
    template = :"wiki/#{page_name}"
    markdown template, options.merge(layout_engine: :haml)
  end

end
