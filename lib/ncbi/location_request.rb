# Locate objects by chromosome and base positions.
module NCBI
  module LocationRequest

    include NCBI::SearchRequest

    def initialize(locations)
      @locations = Array(locations)
      super query_string
    end

    private

    def query_string
      @locations.map(&:to_query_string).join(' +OR+ ')
    end

  end
end
