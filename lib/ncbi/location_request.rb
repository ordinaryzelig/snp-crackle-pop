# Locate objects by chromosome and base positions.
# If only 1 base position is given, widen the search by +/- 1.
# E.g. if base_position_low = 10, then
#   set base_position_low = 9
#   set base_position_high = 11

module NCBI
  module LocationRequest

    include NCBI::SearchRequest

    attr_reader :chromosome
    attr_reader :base_position_low
    attr_reader :base_position_high

    # terms is hash with keys :chromosome, :base_position_low, :base_position_high.
    def initialize(terms)
      terms.with_indifferent_access
      terms.each do |term, value|
        instance_variable_set("@#{term}", value)
      end
      widen_base_position_search if @base_position_low.blank? || @base_position_high.blank?
      super query_string
    end

    # No need to validate.
    def valid?; true; end

    private

    # Compose a query string based on terms hash.
    def query_string
      base_positions = [@base_position_low, @base_position_high].map { |base_position| "#{base_position}[CPOS]" }.join(' : ')
      base_positions = "(#{base_positions})"
      chromosome = "#{@chromosome}[CHR]" if @chromosome
      organism = "human[ORGN]"
      [base_positions, chromosome, organism].compact.join("+AND+")
    end

    # Set base positions to +/- target base_position.
    def widen_base_position_search
      target_base_position = @base_position_low.present? ? @base_position_low.to_i : @base_position_high.to_i
      @base_position_low =  target_base_position - 1
      @base_position_high = target_base_position + 1
    end

  end
end
