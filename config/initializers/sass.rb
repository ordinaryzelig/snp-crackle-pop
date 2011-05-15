require 'sass/plugin/rack'
Sass::Plugin.options[:cache_store] = Sass::CacheStores::Filesystem.new('./tmp')
Sass::Plugin.add_template_location Padrino.root + "/app/views/stylesheets"
SnpCracklePop.use Sass::Plugin::Rack
