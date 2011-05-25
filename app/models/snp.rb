class Snp

  include NCBI::Document

  set_ncbi_base_uri 'http://www.ncbi.nlm.nih.gov/projects/SNP/snp_ref.cgi?rs='
  verify_xml { |doc| doc.css('Rs') }

  field :accession,          type: Integer  # Many accessions, grab all?
  embeds_many :alleles,                        options: {xml: :parse_alleles}, autosave: true
  field :ancestral_allele,   type: String,   xml: proc { |doc| doc.css('Rs > Sequence').first['ancestralAllele'] }
  field :base_position,      type: Integer
  field :chromosome,         type: Integer,  xml: proc { |doc| doc.css('Rs Assembly Component').first['chromosome'] }
  field :gene_symbol,        type: Integer,  xml: proc { |doc| doc.css('Rs Assembly Component MapLoc FxnSet').first['symbol'] }
  field :het_uncertainty,    type: Float,    xml: proc { |doc| doc.css('Rs Het').first['stdError'].to_f.round(3) }
  field :heterozygosity,     type: Float,    xml: proc { |doc| doc.css('Rs Het').first['value'].to_f.round(3) }
  field :max_success_rate,   type: Float,    xml: proc { |doc| doc.css('Rs').first['validProbMax'] }
  field :min_success_rate,   type: Float,    xml: proc { |doc| doc.css('Rs').first['validProbMin'] }
  field :modification_build, type: Integer,  xml: proc { |doc| doc.css('Rs Update').first['build'] }
  field :modification_date,  type: Time,     xml: proc { |doc| doc.css('Rs Update').first['date'] }
  field :ncbi_gene_id,       type: Integer,  xml: proc { |doc| doc.css('Rs Assembly Component MapLoc FxnSet').first['geneId'] }
  field :ncbi_id,            type: Integer,  xml: proc { |doc| doc.css('Rs').first['rsId'] }
  field :ncbi_taxonomy_id,   type: Integer,  xml: proc { |doc| doc.css('Rs').first['taxId']}
  field :reference_assembly, type: Boolean,  xml: proc { |doc| doc.css('Rs Assembly').any? { |assembly| assembly['reference'] == 'true'} }
  field :rs_number,          type: Integer,  xml: proc { |doc| doc.css('Rs').first['rsId'] }
  field :snp_class,          type: String,   xml: proc { |doc| doc.css('Rs').first['snpClass'] }
  ncbi_timestamp_field
  belongs_to :gene

  validates_uniqueness_of :rs_number

  before_create :assign_gene, unless: :gene_id

  scope :for_ncbi_gene_id, ->(ncbi_gene_id) { where(ncbi_gene_id: ncbi_gene_id) }
  scope :without_gene_object, where(gene_id: nil)

  has_taxonomy

  # Custom accepts_nested_attributes_for.
  # If there are existing alleles, update them in the order they are presented.
  # If there are no existing alleles, make new ones.
  def alleles_attributes=(attributes_hash = {})
    atts_hashes = attributes_hash.values # Don't care about index.
    raise "Snp can only have 2 alleles" unless atts_hashes.size == 2
    if alleles.any?
      alleles.each_with_index do |allele, i|
        new_attributes = atts_hashes[i]
        allele.attributes = new_attributes
      end
    else
      atts_hashes.each do |atts|
        alleles.push(Allele.new(atts))
      end
    end
  end

  class << self

    def humanize
      'SNP'
    end

    private

    # Given XML document, construct attributes hash for accepts_nested_attributes_for allele.
    def parse_alleles(document)
      document.css('FxnSet').each_with_index.inject({}) do |attributes, (function_set, i)|
        attributes[i] = Allele.send(:attributes_from_xml, function_set.to_s)
        attributes
      end
    end

  end

  private

  def assign_gene
    self.gene = Gene.find_by_ncbi_id self.ncbi_gene_id
  end

end
