# Represents a chromosome and at least 1 base position.
# A location is used to locate objects on a chromosome within a range of base positions.
# If only 1 base position is given, a range of +/- 1 is assumed.
class Location

  attr_accessor :chromosome
  attr_accessor :base_position_low
  attr_accessor :base_position_high

  def initialize(atts = {})
    atts.each do |att, value|
      send("#{att}=", value)
    end
    assume_base_position_range if atts.any? && (@base_position_low.blank? || @base_position_high.blank?)
  end

  class << self

    # One location per line.
    def new_from_input(input)
      input.split(/\r*\n+/).map do |line|
        chromosome, base_position = line.strip.split(/[^\d]+/).map(&:to_i)
        new(chromosome: chromosome, base_position_low: base_position)
      end
    end

  end

  # Compose query string for search request.
  # E.g. '((9[CPOS] : 11[CPOS])+AND+1[CHR]+AND+human[ORGN])'
  def to_query_string
    base_positions_str = [@base_position_low, @base_position_high].map { |base_position| "#{base_position}[CPOS]" }.join(' : ')
    base_positions_str = "(#{base_positions_str})"
    chromosome_str = "#{@chromosome}[CHR]"
    organism_str = "human[ORGN]"
    query_string = [base_positions_str, chromosome_str, organism_str].compact.join("+AND+")
    "(#{query_string})"
  end

  # Equal to another location if chromosome, and base positions are equal.
  def ==(location)
    [self.chromosome, self.base_position_low, self.base_position_high].all?(&:present?)
    self.chromosome == location.chromosome &&
    self.base_position_low == location.base_position_low &&
    self.base_position_high == location.base_position_high
  end

  private

  def assume_base_position_range
    target_base_position = @base_position_low.present? ? @base_position_low.to_i : @base_position_high.to_i
    @base_position_low =  target_base_position - 1
    @base_position_high = target_base_position + 1
  end

end
