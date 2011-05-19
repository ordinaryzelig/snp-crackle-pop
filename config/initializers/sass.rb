require 'sass/plugin/rack'
SnpCracklePop.use Sass::Plugin::Rack
Sass::Plugin.options.merge!(
  cache_store: Sass::CacheStores::Filesystem.new('./tmp/sass-cache'),
)
Sass::Plugin.add_template_location Padrino.root + "/app/views/stylesheets"
