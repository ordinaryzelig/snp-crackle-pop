# This module enables a class to search NCBI, parse the response, and assign attributes.
# Searching NCBI is a 2-step process:
#   1) Use Entrez.ESearch to search for terms. It returns ids of matching objects.
#   2) Use Entrez.ESummary to get document summaries of those ids.

module NCBI
  module SearchRequest

    include HTTPartyResponse

    attr_reader :search_terms
    attr_reader :ids
    attr_reader :results
    attr_reader :search_term

    delegate :ncbi_database_name, to: :parent

    def initialize(search_terms)
      @search_terms = search_terms
    end

    # Validates that @search_term (singular, i.e. the word that is being searched)
    # is a number or at least 3 characters.
    def valid?
      begin
        # Attempt to convert to number.
        !!Float(@search_term)
      rescue
        # @search_term cannot be coerced into number, must be non-number string,
        # and it should be >=3 characters.
        @search_term.size >= 3
      end
    end

    def execute
      validate_search_term
      search_for_ncbi_ids
      get_results_from_ids
      results
    end

    def parent
      self.class.parent
    end

    private

    def validate_search_term
      raise NotEnoughCharacters.new(@search_term) unless valid?
    end

    # Use Entrez.ESearch to get ids.
    def search_for_ncbi_ids
      esearch = Entrez.ESearch(ncbi_database_name, @search_terms)
      # TODO: doesn't Entrez have a sorting option?
      # Uniq the array. Sometimes ESearch uselessly returns more than 1 id.
      @ids = esearch.ids.uniq.sort
    end

    # Use Entrez.ESearch to get document summaries from ids.
    # Assign to @results.
    def get_results_from_ids
      @response = Entrez.ESummary(ncbi_database_name, id: @ids)
      # URL is too long, probably because there are too many results for NCBI server.
      raise SearchTooBroad.new(@ids) if @response.code == 414
      @results = parent::SearchResult.new_from_splitting_xml(xml)
    end

    class NotEnoughCharacters < DisplayableError
      def initialize(term)
        super "Search requires at least 3 characters: #{term}"
      end
    end

    class SearchTooBroad < DisplayableError
      def initialize(ids)
        super "Search is too broad: #{ids.size} results"
      end
    end

  end
end
