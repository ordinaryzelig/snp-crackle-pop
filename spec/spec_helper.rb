require 'rubygems'
require 'spork'

Spork.prefork do
  ENV["PADRINO_ENV"] ||= "test"
  require File.expand_path("config/boot.rb", Dir.pwd)
  RSpec.configure do |config|
    config.mock_with :mocha
    config.before :each do
      drop_tables
    end
  end
  require 'capybara/rspec'
  Capybara.app = SnpCracklePop
  SnpCracklePop.setup_application!
end

Spork.each_run do
  # require files in support dir.
  Dir[File.expand_path("../support/**/*.rb", __FILE__)].each {|f| require f}
  RSpec.configure do |config|
    config.include(ExampleMacros)
    config.extend(DescriptionMacros)
  end
end
