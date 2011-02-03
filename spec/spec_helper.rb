# boot padrino so we have access to models et al.
require File.expand_path("../../config/boot", __FILE__)

# require files in support dir.
Dir[File.expand_path("../support/**/*.rb", __FILE__)].each {|f| require f}

#DatabaseCleaner.strategy = :truncation

RSpec.configure do |config|
  config.include(Macros)
  config.before do
    #DatabaseCleaner.clean
  end
end
