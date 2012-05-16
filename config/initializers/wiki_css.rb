# Middleware to inject a div wrapper with id template for wiki pages.
# This gives us a few things:
#   We can copy/paste gollum's template.css (which was renamed here to wiki.css).
#   We don't have to use a different template just for the wiki.
#   We can use the MarkDown rendering engine.
class GollumTemplateWrapper

  def initialize(app)
    @app = app
  end

  # Wrap whatever is inside the #main div with another div.
  # This div should have id = "template".
  def call(env)
    status, headers, response = @app.call(env)

    # Only do something if:
    #   this is an HTML request,
    #   the request is for the wiki controller,
    #   the status is 200.
    is_html = headers.fetch('Content-Type', '').include?('text/html')
    is_wiki = env['REQUEST_PATH'] =~ /^\/wiki/
    if is_html && is_wiki && status == 200
      body = response.first

      doc = Nokogiri.HTML(body)
      main_div = doc.at_css('#main')

      # Create template div.
      template_div = Nokogiri::XML::Node.new('div', doc)
      template_div['id'] = 'template'

      # Inject template_div as wrapper inside main_div.
      # Transfer main_div's children to template_div.
      # Then reassign main_div's children to template_div,
      template_div.children = main_div.children
      main_div.children = Nokogiri::XML::NodeSet.new(doc, [template_div])

      # Construct new response with new body.
      body = doc.to_html.html_safe
      response = [body]
      headers['Content-Length'] = body.size.to_s
    end
    [status, headers, response]
  end

private


end
Padrino.middleware << GollumTemplateWrapper
