source :rubygems

# Padrino
gem 'padrino', '0.9.29'

# Project requirements
gem 'rake', '0.8.7'
gem 'rack-flash', '0.1.1'
gem 'thin', '1.2.7' # or mongrel

# Component requirements
gem 'bson_ext', '1.3.1'
gem 'entrez', '0.5.8.1'
gem 'haml', '3.1.1'
gem 'mongoid', '2.0.0.rc.7'
gem 'nokogiri', '1.4.4'
gem 'sass', '3.1.1'
gem 'mongoid_to_csv', '0.4.0'

# Wiki.
gem 'rdiscount', '1.6.8'

group :test do
  gem 'capybara', '~>0.4.1'
  gem 'fakeweb', '1.3.0'
  gem 'launchy', '0.4.0'
  gem 'machinist_mongo', '1.2.0', require: 'machinist/mongoid'
  gem 'mocha', '0.9.12'
  gem 'rspec', '2.6.0'
  gem 'spork', '0.8.5'
  gem 'vcr', '2.1.1'
end

group :development do
  gem 'foreman', '0.46.0'
  gem 'guard-spork', '0.8.0'
end

group :development, :test do
  gem 'awesome_print'
end
