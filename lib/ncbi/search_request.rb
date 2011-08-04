# This module enables a class to search NCBI, parse the response, and assign attributes.
# Searching NCBI is a 2-step process:
#   1) Use Entrez.ESearch to search for terms. It returns ids of matching objects.
#   2) Use Entrez.ESummary to get document summaries of those ids.

module NCBI
  module SearchRequest

    def self.included(target)
      target.send :include, HTTPartyResponse
      target.class_eval do
        attr_reader :search_terms
        attr_reader :ids
        attr_reader :results
        attr_reader :search_term
      end
    end

    def initialize(search_terms)
      @search_terms = search_terms
      @database_name = self.class.parent.ncbi_database_name
    end

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

    private

    def validate_search_term
      raise NotEnoughCharacters.new(@search_term) unless valid?
    end

    # Use Entrez.ESearch to get ids.
    def search_for_ncbi_ids
      esearch = Entrez.ESearch(@database_name, @search_terms)
      # TODO: doesn't Entrez have a sorting option?
      @ids = esearch.ids.sort
    end

    # Use Entrez.ESearch to get document summaries from ids.
    # Assign to @results.
    def get_results_from_ids
      @response = Entrez.ESummary(@database_name, id: @ids)
      # URL is too long, probably because there are too many results for NCBI server.
      raise SearchTooBroad.new(@ids) if @response.code == 414
      @results = self.class.parent::SearchResult.parse_esummary(xml)
    end

    class NotEnoughCharacters < StandardError
      def initialize(term)
        super "Search requires at least 3 characters: #{term}"
      end
    end

    class SearchTooBroad < StandardError
      def initialize(ids)
        super "Search is too broad: #{ids.size} results"
      end
    end

  end
end
