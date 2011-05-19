case Padrino.env
when :production
  # Use MongoHQ Heroku addon.
  uri = URI.parse(ENV['MONGOHQ_URL'])
  conn = Mongo::Connection.from_uri(ENV['MONGOHQ_URL'])
  db = conn.db(uri.path.gsub(/^\//, ''))
when :development, :test
  # Connect to local
  host = 'localhost'
  port = Mongo::Connection::DEFAULT_PORT
  database_name = case Padrino.env
    when :development then 'snp_crackle_pop_development'
    when :test        then 'snp_crackle_pop_test'
  end
  Mongoid.database = Mongo::Connection.new(host, port).db(database_name)
else
  raise "No database configuration for #{Padrino.env} environment"
end
