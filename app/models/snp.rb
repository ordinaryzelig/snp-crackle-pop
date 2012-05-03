class Snp

  include NCBI::Document
  extend NCBI::Locatable

  set_ncbi_base_uri 'http://www.ncbi.nlm.nih.gov/projects/SNP/snp_ref.cgi?rs='
  split_xml_on { |doc| doc.css('Rs') }
  verify_xml { |node| node.attributes['rsId'] }
  set_unique_id_field :rs_number
  set_unique_id_search_field :RS

  field :ancestral_allele,       type: String,  xml: lambda { |node| node.css('Sequence').first['ancestralAllele'] }
  field :refSNP_alleles,         type: Array,   default: [], xml: lambda { |node| node.at_css('Sequence Observed').text.split('/') }
  field :chromosome,             type: Integer, xml: lambda { |node| node.css('Assembly Component').first['chromosome'] }
  field :gene_symbol,            type: Integer, xml: lambda { |node| node.css('Assembly Component MapLoc FxnSet').first['symbol'] }
  field :has_associations,       type: Boolean
  field :het_uncertainty,        type: Float,   xml: lambda { |node| node.css('Het').first['stdError'].to_f.round(3) }
  field :heterozygosity,         type: Float,   xml: lambda { |node| node.css('Het').first['value'].to_f.round(3) }
  field :max_success_rate,       type: Float,   xml: lambda { |node| node.css('validProbMax').first }
  field :min_success_rate,       type: Float,   xml: lambda { |node| node.css('validProbMin').first }
  field :minor_allele,           type: String,  xml: lambda { |node| node.at_css('Frequency')[:allele] }
  field :minor_allele_frequency, type: Float,   xml: lambda { |node| node.at_css('Frequency')[:freq].to_f }
  field :modification_build,     type: Integer, xml: lambda { |node| node.css('Update').first['build'] }
  field :modification_date,      type: Time,    xml: lambda { |node| node.css('Update').first['date'] }
  field :ncbi_gene_id,           type: Integer, xml: lambda { |node| node.css('Assembly Component MapLoc FxnSet').first['geneId'] }
  field :ncbi_id,                type: Integer, xml: lambda { |node| node['rsId'] }
  field :ncbi_taxonomy_id,       type: Integer, xml: lambda { |node| node['taxId'] }
  field :protein_accession,      type: String,  xml: lambda { |node| node.css('FxnSet').first['protAcc'] }
  field :protein_version,        type: Integer, xml: lambda { |node| node.css('FxnSet').first['protVer'] }
  field :rs_number,              type: Integer, xml: lambda { |node| node['rsId'] }
  field :snp_class,              type: String,  xml: lambda { |node| node['snpClass'] }
  ncbi_timestamp_field

  embeds_many :alleles,    autosave: true, options: {xml: lambda { |node| node.css('Assembly').detect { |fxnset| fxnset[:reference] == 'true' }.css('FxnSet') } }
  embeds_many :assemblies, autosave: true, options: {xml: lambda { |node| node.css('Assembly') }}
  belongs_to :gene

  validates_uniqueness_of :rs_number

  before_create :assign_gene, unless: :gene_id
  before_create :fetch_associations, unless: :has_associations

  scope :for_ncbi_gene_id, ->(ncbi_gene_id) { where(ncbi_gene_id: ncbi_gene_id) }
  scope :without_gene_object, where(gene_id: nil)

  has_taxonomy

  class << self

    def humanize
      'SNP'
    end

  end

  def protein_accession_str
    return nil unless protein_accession.present? && protein_version.present?
    "#{protein_accession}.#{protein_version}"
  end

  private

  def assign_gene
    self.gene = Gene.find_by_ncbi_id self.ncbi_gene_id
  end

  def fetch_associations
    snp_association = SnpAssociation.fetch(self.rs_number)
    self.has_associations = snp_association.present?
    true
  end

  class LocationRequest
    include NCBI::LocationRequest
  end

  class UniqueIdSearchRequest
    include NCBI::UniqueIdSearchRequest
    # Prepend 'rs' if not already prepended.
    def initialize(rs_numbers)
      ids = [rs_numbers].flatten
      ids.map! { |id| id =~ /^rs/ ? id : "rs#{id}" }
      super ids
    end
  end

  class SearchResult

    include NCBI::SearchResult

    field(:base_position)  { |node| node.items['CHRPOS'].match(/\d:(?<base_position>\d+)/)[:base_position].to_i }
    field(:chromosome)     { |node| node.items['CHR'].to_i }
    field(:function_class) { |node| node.items['FXN_CLASS'] }
    field(:merged_with)    { |node| if match = node.items['TEXT'].match(/MergedRs=(?<rs>\d+)/) then match[:rs].to_i end }
    field(:rs_number)      { |node| "rs#{node.items['SNP_ID']}" } # Prepend 'rs' just for convenience when validating unique id search results.
    field(:snp_class)      { |node| node.items['SNP_CLASS'] }

    def discontinued
      merged_with.present?
    end

  end

end
