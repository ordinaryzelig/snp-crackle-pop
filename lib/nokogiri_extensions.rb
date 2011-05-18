class Nokogiri::XML::Document

  # Simple wrapper to pull out xml info from document.
  # Raises ParseError exception with field_name for better debugging.
  def extract(field_name, procedure)
    procedure.call(self)
  rescue Exception => ex
    raise NCBI::Document::ParseError.new(self, field_name, ex)
  end

end
