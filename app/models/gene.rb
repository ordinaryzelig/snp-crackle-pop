class Gene

  include NCBI::Document

  verify_xml { |node| node.css('Entrezgene_track-info').first }
  split_xml_on { |doc| doc.css('Entrezgene') }
  set_ncbi_base_uri 'http://www.ncbi.nlm.nih.gov/gene/'

  field :description,      type: String,  xml: proc { |node| node.css('Gene-ref_desc').first.content }
  field :diseases,         type: Array,   xml: proc { |node| node.css('Entrezgene_comments > Gene-commentary > Gene-commentary_comment > Gene-commentary > Gene-commentary_type').select { |node| node['value'] == 'phenotype' }.map { |node| node.next.next.content } }
  field :location,         type: String,  xml: proc { |node| node.css('Gene-ref_maploc').first.content }
  field :mim,              type: Integer, xml: proc { |node| node.css('Entrezgene_unique-keys Dbtag_db').detect { |node| node.content == 'MIM' }.next.next.css('Object-id_id').first.content }
  field :ncbi_id,          type: Integer, xml: proc { |node| node.css('Gene-track_geneid').first.content }
  field :ncbi_taxonomy_id, type: Integer, xml: proc { |node| node.css('Org-ref_db Dbtag Dbtag_tag Object-id Object-id_id').first.content }
  field :protein_name,     type: String,  xml: proc { |node| node.css('Prot-ref_name_E').first.content }
  field :symbol,           type: String,  xml: proc { |node| node.css('Gene-ref_locus').first.content }
  field :symbols_other,    type: Array,   xml: proc { |node| node.css('Gene-ref_syn Gene-ref_syn_E').map(&:content) }
  ncbi_timestamp_field
  alias_method :name, :symbol

  has_many :snps

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

  class << self

    def search_local(term)
      return [] if term.blank?
      reg_exp = Regexp.new(term, true)
      conditions = [:location, :description, :protein_name, :symbol, :symbols_other].map do |field_to_search|
        {field_to_search => reg_exp}
      end
      any_of(conditions)
    end

    # Search NCBI for term in name, symbols and location.
    # Return array of search result objects.
    # Limits to human organisms.
    def search_NCBI(term)
      ors = {
        :GENE                   => "*#{term}*",
        :'DEFAULT MAP LOCATION' => term,
      }
      query_string = "human[ORGN]+AND+" + Entrez.convert_search_term_hash(ors, 'OR')
      request = SearchRequest.new(query_string)
      request.execute
    end

  end

  class SearchRequest
    include NCBI::SearchRequest
    #field :title, :TITL
    #field :description
  end

  class SearchResult
    include NCBI::SearchResult
    field(:description)   { |doc| doc.items['Description'] }
    field(:location)      { |doc| doc.items['MapLocation'] }
    field(:symbol)        { |doc| doc.items['NomenclatureSymbol'] }
    field(:symbols_other) { |doc| doc.items['OtherAliases'].split(', ') }
    field(:other)         { |doc| doc.items['OtherDesignations'] }
  end

end
