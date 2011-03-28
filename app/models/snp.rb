class Snp

  include NCBIRecord

  set_entrez_id_field :rs_number

  field :rs_number,              type: Integer, xml: proc { |doc| doc.css('Rs').first['rsId'] }
  field :chromosome,             type: Integer, xml: proc { |doc| doc.css('Rs Assembly Component').first['chromosome'] }
  field :gene,                   type: String,  xml: proc { |doc| doc.css('Rs Assembly Component MapLoc FxnSet').first['symbol'] }
  field :accession,              type: Integer  # Many accessions, grab all?
  field :tax_id,                 type: Integer, xml: proc { |doc| doc.css('Rs').first['taxId']}
  field :function_class,         type: Integer
  field :not_reference_assembly, type: Boolean, xml: proc { |doc| doc.css('Rs Assembly').first['reference'] }
  field :heterozygosity,         type: Float,   xml: proc { |doc| doc.css('Rs Het').first['value'].to_f().round(3) }
  field :het_uncertainty,        type: Float,   xml: proc { |doc| doc.css('Rs Het').first['stdError'].to_f().round(3) }
  field :min_success_rate,       type: Float,   xml: proc { |doc| doc.css('Rs').first['validProbMin'].to_f() }
  field :max_success_rate,       type: Float,   xml: proc { |doc| doc.css('Rs').first['validProbMax'].to_f() }
  field :allele,                 type: String
  field :snp_class,              type: String,  xml: proc { |doc| doc.css('Rs').first['snpClass'] }
  field :base_position,          type: Integer

  index :rs_number, unique: true

  validates_uniqueness_of :rs_number

  # Thought about using referenced_in/references_many, but
  # then we'd have to store mongo ids and that seems like overkill.
  def taxonomy
    Taxonomy.find_by_entrez_id_or_fetch!(tax_id)
  end

end
