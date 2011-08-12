class Gene

  include NCBI::Document
  extend NCBI::Locatable

  verify_xml { |node| node.css('Entrezgene_track-info').first }
  split_xml_on { |doc| doc.css('Entrezgene') }
  set_ncbi_base_uri 'http://www.ncbi.nlm.nih.gov/gene/'
  set_unique_id_field :symbol
  set_unique_id_search_field :GENE

  field :description,            type: String,  xml: lambda { |node| node.css('Gene-ref_desc').first.content }
  field :diseases,               type: Array,   xml: lambda { |node| node.css('Entrezgene_comments > Gene-commentary > Gene-commentary_comment > Gene-commentary > Gene-commentary_type').select { |node| node['value'] == 'phenotype' }.map { |node| node.next.next.content } }
  field :discontinued,           type: Boolean, xml: lambda { |node| node.css('Gene-track_discontinue-date').present? }
  field :location,               type: String,  xml: lambda { |node| node.css('Gene-ref_maploc').first.content }
  field :mim,                    type: Integer, xml: lambda { |node| node.css('Entrezgene_unique-keys Dbtag_db').detect { |node| node.content == 'MIM' }.next.next.css('Object-id_id').first.content }
  field :ncbi_id,                type: Integer, xml: lambda { |node| node.css('Gene-track_geneid').first.content }
  field :ncbi_taxonomy_id,       type: Integer, xml: lambda { |node| node.css('Org-ref_db Dbtag Dbtag_tag Object-id Object-id_id').first.content }
  field :protein_name,           type: String,  xml: lambda { |node| node.css('Prot-ref_name_E').first.content }
  # Sequence data uses first matching occurrence in XML even though there may be multiples.
  # Minimal testing shows "Genomic context" on NCBI site to match 1st occurrence.
  field :sequence_accession,     type: String,  xml: lambda { |node| node.css('Entrezgene_locus Gene-commentary Gene-commentary_accession').first.content }
  field :sequence_interval_from, type: Integer, xml: lambda { |node| node.css('Entrezgene_locus Gene-commentary Gene-commentary_seqs Seq-loc Seq-loc_int Seq-interval Seq-interval_from').first.content }
  field :sequence_interval_to,   type: Integer, xml: lambda { |node| node.css('Entrezgene_locus Gene-commentary Gene-commentary_seqs Seq-loc Seq-loc_int Seq-interval Seq-interval_to').first.content }
  field :sequence_version,       type: Integer, xml: lambda { |node| node.css('Entrezgene_locus Gene-commentary Gene-commentary_version').first.content }
  field :symbol,                 type: String,  xml: lambda { |node| node.css('Gene-ref_locus').first.content }
  field :symbols_other,          type: Array,   xml: lambda { |node| node.css('Gene-ref_syn Gene-ref_syn_E').map(&:content) }
  ncbi_timestamp_field
  alias_method :name, :symbol

  has_many :snps

  validates_uniqueness_of :symbol

  has_taxonomy

  # For any Snps that have the same gene_id,
  # but don't yet have a gene object in the db,
  # assign this one to them.
  def assign_to_child_snps
    Snp.without_gene_object.for_ncbi_gene_id(self.ncbi_id).update_all(gene_id: self.id)
  end

  def name_and_description
    "#{name}: #{description}"
  end

  def all_symbols
    [symbol] + symbols_other
  end

  def sequence_range
    return nil unless [:sequence_accession, :sequence_version, :sequence_interval_from, :sequence_interval_to].all? { |field| send(field).present? }
    "#{sequence_accession}.#{sequence_version} (#{sequence_interval_from}..#{sequence_interval_to})"
  end

  def sequence_length
    return nil unless sequence_interval_to.present? && sequence_interval_from.present?
    sequence_interval_to - sequence_interval_from + 1
  end

  class << self

    # Search NCBI for term in name, symbols and location.
    # Return array of search result objects.
    def search(term)
      request = SearchRequest.new(term)
      request.execute
    end

  end

  # Search NCBI for term in name, symbols and location.
  # Limits to human organisms.
  class SearchRequest

    include NCBI::SearchRequest

    # Construct query string from term.
    # Pass query string to super.
    def initialize(search_term)
      @search_term = search_term
      ors = {
        :GENE                   => "*#{@search_term}*",
        :'DEFAULT MAP LOCATION' => @search_term,
      }
      query_string = "human[ORGN]+AND+" + Entrez.convert_search_term_hash(ors, 'OR')
      super(query_string)
    end

  end

  # Search by symbol and return exactly 1 result.
  class UniqueIdSearchRequest
    include NCBI::UniqueIdSearchRequest
  end

  # Locate objects by chromosome and base positions.
  class LocationRequest
    include NCBI::LocationRequest
  end

  class SearchResult
    include NCBI::SearchResult
    field(:description)   { |node| node.items['Description'] }
    field(:discontinued)  { |node| node.items['CurrentID'] != 0 }
    field(:location)      { |node| node.items['MapLocation'] }
    field(:symbol)        { |node| node.items['Name'] }
    field(:symbols_other) { |node| node.items['OtherAliases'].split(', ') }
    field(:other)         { |node| node.items['OtherDesignations'] }
  end

end
