SnpCracklePop.helpers do

  def csv(data, file_name)
    content_type 'text/csv'
    attachment file_name
    halt data
  end

end
