# Note: NCBI has renamed Genome Project to BioProject.
# 2011-05-19 Tried changing database name from genomeprj to bioproject, but that didn't work.

class GenomeProject

  include NCBI::Document

  set_ncbi_database_name 'genomeprj'
  set_ncbi_base_uri 'http://www.ncbi.nlm.nih.gov/bioproject/'
  split_xml_on { |doc| doc.css('DocSum') }
  verify_xml { |node| node.css('Id') }

  field :name,               type: String,  xml: proc { |node| node.xpath('.//Item[@Name="Defline"]').first.content }
  field :ncbi_taxonomy_id,   type: Integer, xml: proc { |node| node.xpath('.//Item[@Name="TaxId"]').first.content }
  field :ncbi_id,            type: Integer, xml: proc { |node| node.xpath('.//Id').first.content }
  field :sequencing_centers, type: Array,   xml: proc { |node| node.xpath('.//Item[@Name="Center"]').map(&:content) }
  field :sequencing_status,  type: String,  xml: proc { |node| node.xpath('.//Item[@Name="Sequencing_Status"]').first.content }
  ncbi_timestamp_field

  has_taxonomy

  class << self

    # Search name and sequencing centers.
    def search(name)
      reg_exp = Regexp.new(Regexp.escape(name), true)
      conditions = [:name, :sequencing_centers].map do |field_to_search|
        {field_to_search => reg_exp}
      end
      any_of(conditions)
    end

    def search_local(term)
      return [] if term.blank?
      reg_exp = Regexp.new(term, true)
      conditions = [:name, :ncbi_id, :sequencing_centers].map do |field_to_search|
        {field_to_search => reg_exp}
      end
      any_of(conditions)
    end

    def search_NCBI(term)
      search_request = SearchRequest.new(ALL: "*#{term}*")
      search_request.execute
    end

    private

    # Customize fetching data using ESummary instead of EFetch.
    def perform_entrez_request(ncbi_id)
      Entrez.ESummary(ncbi_database_name, id: ncbi_id)
    end

  end

  class SearchRequest
    include NCBI::SearchRequest
  end

  class SearchResult
    include NCBI::SearchResult
    field(:name)               { |doc| doc.items['Defline'] }
    field(:sequencing_centers) { |doc| doc.items['Center'] }
  end

end
