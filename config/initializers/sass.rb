require 'sass/plugin/rack'
Sass::Plugin.options[:cache_location] = './tmp/sass-cache'
Sass::Plugin.add_template_location Padrino.root + "/app/views/stylesheets"
SnpCracklePop.use Sass::Plugin::Rack
