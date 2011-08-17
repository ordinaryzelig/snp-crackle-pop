class Taxonomy

  include NCBI::Document

  split_xml_on { |doc| doc.css('Taxon') }
  verify_xml { |node| node.css('TaxId').first }

  field :common_name,         type: String, xml: lambda { |node| node.css('OtherNames CommonName').first.content }
  field :genbank_common_name, type: String, xml: lambda { |node| node.css('OtherNames GenbankCommonName').first.content }
  field :ncbi_id,             type: Integer, xml: lambda { |node| node.css('TaxId').first.content }
  field :scientific_name,     type: String, xml: lambda { |node| node.css('ScientificName').first.content }
  ncbi_timestamp_field

end
