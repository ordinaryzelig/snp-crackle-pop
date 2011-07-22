SnpCracklePop.helpers do

  # This is maybe more Padrino-ish to register as a Tilt template.
  def csv(data, file_name)
    content_type 'text/csv'
    attachment file_name
    halt data
  end

end
