require 'rubygems'
require 'spork'

Spork.prefork do

  ENV["PADRINO_ENV"] ||= "test"
  require File.expand_path("config/boot.rb", Dir.pwd)

  # require files in support dir.
  Dir[File.expand_path("../support/**/*.rb", __FILE__)].each {|f| require f}
  RSpec.configure do |config|
    config.mock_with :mocha
    config.before :each do
      drop_tables
    end
    config.include(ExampleMacros)
    config.extend(DescriptionMacros)
  end

  require 'capybara/rspec'
  Capybara.app = SnpCracklePop

  SnpCracklePop.setup_application!

  require 'entrez/spec_helpers'
  Entrez.ignore_query_limit = true

  # VCR.
  VCR.configure do |c|
    c.cassette_library_dir = 'spec/support/vcr_cassettes'
    c.hook_into :fakeweb
    c.allow_http_connections_when_no_cassette = true
  end

end

Spork.each_run do
  # Spork (I think) kills Time.zone, so load it at each run.
  load Padrino.root + '/config/initializers/time_zone.rb'
end
