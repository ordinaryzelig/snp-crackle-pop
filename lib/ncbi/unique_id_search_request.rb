# Searching by unique ID should only return 1 valid object per given identifier.

module NCBI
  module UniqueIdSearchRequest

    include SearchRequest

    delegate :unique_id_search_field, to: :parent

    def initialize(search_ids)
      @search_ids = [search_ids].flatten
      field_query_string = @search_ids.map { |id| "#{id}[#{unique_id_search_field}]" }.join('+OR+')
      query_string = "(#{field_query_string})+AND+human[ORGN]"
      super query_string
    end

    # After normal execution, filter out discontinueds.
    # Return single result.
    def execute
      super
      results.reject!(&:discontinued?)
      validate_results
      results
    end

    private

    # Each id submitted must be found exactly 1 time.
    def validate_results
      @search_ids.each do |id|
        found = results.select { |r| r.unique_identifier.to_s =~ Regexp.new(id, true) }
        case found.size
        when 0
          raise NotFound.new(id, self.class.parent)
        when 1
          # Search produced single result, which makes it unique.
        else
          raise NotUnique.new(id, found.size, self.class.parent)
        end
      end
    end

    class NotFound < DisplayableError
      def initialize(id, model_class)
        super "#{model_class.humanize} search could not find '#{id}'"
      end
    end

    class NotUnique < DisplayableError
      def initialize(id, num_found, model_class)
        super "#{model_class.humanize} identifier '#{id}' is not unique: searching found #{num_found} results"
      end
    end

  end
end
