class Taxonomy

  extend NCBIRecord

  set_entrez_id_field :tax_id

  field :tax_id, type: Integer, xml: proc { |doc| doc.css('Taxon TaxId').first.content }
  field :scientific_name, type: String, xml: proc { |doc| doc.css('Taxon ScientificName').first.content }
  field :genbank_common_name, type: String, xml: proc { |doc| doc.css('Taxon OtherNames GenbankCommonName').first.content }
  field :common_name, type: String, xml: proc { |doc| doc.css('Taxon OtherNames CommonName').first.content }
  
  referenced_in :snp



  index :taxid, unique: true

  validates_uniqueness_of :taxid

end
