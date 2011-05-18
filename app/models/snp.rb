class Snp

  include NCBI::Document

  verify_xml { |doc| doc.css('Rs') }

  field :accession,          type: Integer  # Many accessions, grab all?
  field :allele,             type: String
  field :base_position,      type: Integer
  field :chromosome,         type: Integer, xml: proc { |doc| doc.css('Rs Assembly Component').first['chromosome'] }
  field :function_class,     type: Integer
  field :gene_symbol,        type: Integer, xml: proc { |doc| doc.css('Rs Assembly Component MapLoc FxnSet').first['symbol'] }
  field :het_uncertainty,    type: Float,   xml: proc { |doc| doc.css('Rs Het').first['stdError'].to_f.round(3) }
  field :heterozygosity,     type: Float,   xml: proc { |doc| doc.css('Rs Het').first['value'].to_f.round(3) }
  field :max_success_rate,   type: Float,   xml: proc { |doc| doc.css('Rs').first['validProbMax'] }
  field :min_success_rate,   type: Float,   xml: proc { |doc| doc.css('Rs').first['validProbMin'] }
  field :ncbi_gene_id,       type: Integer, xml: proc { |doc| doc.css('Rs Assembly Component MapLoc FxnSet').first['geneId'] }
  field :ncbi_id,            type: Integer, xml: proc { |doc| doc.css('Rs').first['rsId'] }
  field :ncbi_taxonomy_id,   type: Integer, xml: proc { |doc| doc.css('Rs').first['taxId']}
  field :reference_assembly, type: Boolean, xml: proc { |doc| doc.css('Rs Assembly').any? { |assembly| assembly['reference'] == 'true'} }
  field :rs_number,          type: Integer, xml: proc { |doc| doc.css('Rs').first['rsId'] }
  field :snp_class,          type: String,  xml: proc { |doc| doc.css('Rs').first['snpClass'] }
  ncbi_timestamp_field
  belongs_to :gene

  validates_uniqueness_of :rs_number

  before_create :assign_gene, unless: :gene_id

  scope :for_ncbi_gene_id, ->(ncbi_gene_id) { where(ncbi_gene_id: ncbi_gene_id) }
  scope :without_gene_object, where(gene_id: nil)

  has_taxonomy

  private

  def assign_gene
    self.gene = Gene.find_by_ncbi_id self.ncbi_gene_id
  end

end
