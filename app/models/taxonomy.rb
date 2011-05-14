class Taxonomy

  include NCBIRecord

  set_entrez_id_field :tax_id

  field :common_name, type: String, xml: proc { |doc| doc.css('Taxon OtherNames CommonName').first.content }
  field :genbank_common_name, type: String, xml: proc { |doc| doc.css('Taxon OtherNames GenbankCommonName').first.content }
  field :scientific_name, type: String, xml: proc { |doc| doc.css('Taxon ScientificName').first.content }
  field :tax_id, type: Integer, xml: proc { |doc| doc.css('Taxon TaxId').first.content }

  validates_uniqueness_of :tax_id

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
