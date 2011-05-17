# Connection.new takes host, port
host = 'localhost'
port = Mongo::Connection::DEFAULT_PORT

database_name = case Padrino.env
  when :development then 'snp_crackle_pop_development'
  when :production  then 'snp_crackle_pop_production'
  when :test        then 'snp_crackle_pop_test'
end

Mongoid.database = Mongo::Connection.new(host, port).db(database_name)
