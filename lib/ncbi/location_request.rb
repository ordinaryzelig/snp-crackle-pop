# Locate objects by chromosome and base positions.

module NCBI
  module LocationRequest

    include NCBI::SearchRequest

    # terms is hash with keys :chromosome, :base_position_low, :base_position_high.
    def initialize(terms)
      super query_string(terms)
    end

    # No need to validate.
    def valid?; true; end

    private

    # Compose a query string based on terms hash.
    def query_string(terms)
      terms.with_indifferent_access
      base_positions = [:base_position_low, :base_position_high].map { |field| "#{terms[field]}[CPOS]" }.join(' : ')
      base_positions = "(#{base_positions})"
      chromosome = "#{terms[:chromosome]}[CHR]" if terms[:chromosome]
      organism = "human[ORGN]"
      [base_positions, chromosome, organism].compact.join("+AND+")
    end

  end
end
