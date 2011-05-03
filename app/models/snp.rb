class Snp

  include NCBIRecord

  set_entrez_id_field :rs_number

  field :accession,          type: Integer  # Many accessions, grab all?
  field :allele,             type: String
  field :base_position,      type: Integer
  field :chromosome,         type: Integer, xml: proc { |doc| doc.css('Rs Assembly Component').first['chromosome'] }
  field :function_class,     type: Integer
  field :gene,               type: String,  xml: proc { |doc| doc.css('Rs Assembly Component MapLoc FxnSet').first['symbol'] }
  field :het_uncertainty,    type: Float,   xml: proc { |doc| doc.css('Rs Het').first['stdError'].to_f.round(3) }
  field :heterozygosity,     type: Float,   xml: proc { |doc| doc.css('Rs Het').first['value'].to_f.round(3) }
  field :max_success_rate,   type: Float,   xml: proc { |doc| doc.css('Rs').first['validProbMax'] }
  field :min_success_rate,   type: Float,   xml: proc { |doc| doc.css('Rs').first['validProbMin'] }
  field :reference_assembly, type: Boolean, xml: proc { |doc| doc.css('Rs Assembly').any? { |assembly| assembly['reference'] == 'true'} }
  field :rs_number,          type: Integer, xml: proc { |doc| doc.css('Rs').first['rsId'] }
  field :snp_class,          type: String,  xml: proc { |doc| doc.css('Rs').first['snpClass'] }
  field :tax_id,             type: Integer, xml: proc { |doc| doc.css('Rs').first['taxId']}

  index :rs_number, unique: true

  validates_uniqueness_of :rs_number

  # Thought about using referenced_in/references_many, but
  # then we'd have to store mongo ids and that seems like overkill.
  def taxonomy
    Taxonomy.find_by_entrez_id_or_fetch!(tax_id)
  end

end
