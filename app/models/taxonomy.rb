class Taxonomy

  include NCBI::Document

  split_xml_on { |doc| doc.css('Taxon') }
  verify_xml { |node| node.css('TaxId').first }

  field :common_name,         type: String, xml: proc { |node| node.css('OtherNames CommonName').first.content }
  field :genbank_common_name, type: String, xml: proc { |node| node.css('OtherNames GenbankCommonName').first.content }
  field :ncbi_id,             type: Integer, xml: proc { |node| node.css('TaxId').first.content }
  field :scientific_name,     type: String, xml: proc { |node| node.css('ScientificName').first.content }
  ncbi_timestamp_field

  class << self

    # Search scientific_name, genbank_common_name, and common_name.
    def search(name)
      reg_exp = Regexp.new(name, true)
      conditions = [:scientific_name, :genbank_common_name, :common_name].map do |field_to_search|
        {field_to_search => reg_exp}
      end
      any_of(conditions)
    end

  end

end
