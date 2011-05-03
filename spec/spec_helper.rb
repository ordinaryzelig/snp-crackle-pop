require 'rubygems'
require 'spork'

Spork.prefork do
  # Spork::AppFramework::Padrino will load environment.
  RSpec.configure do |config|
    config.mock_with :mocha
    config.before :each do
      drop_tables
    end
  end
end

Spork.each_run do
  # require files in support dir.
  Dir[File.expand_path("../support/**/*.rb", __FILE__)].each {|f| require f}
  RSpec.configure do |config|
    config.include(ExampleMacros)
    config.extend(DescriptionMacros)
  end
end
