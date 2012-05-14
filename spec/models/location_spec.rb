require 'spec_helper'

describe Location do

  it 'widens range to +/- 1 if only 1 base position given' do
    location = Location.new(chromosome: 1, base_position_low: 10)
    location.base_position_low.should == 9
    location.base_position_high.should == 11
  end

  specify '#to_query_string constructs a search request query string' do
    location = Location.new(chromosome: 1, base_position_low: 10)
    location.to_query_string.should == '((9[CPOS] : 11[CPOS])+AND+1[CHR]+AND+human[ORGN])'
  end

  specify '.new_from_input creates locations based on form input' do
    input = <<-END
      6, 32363843
      6;53679328
    END
    locations = Location.new_from_input(input)
    loc_1, loc_2 = locations
    loc_1.should == Location.new(chromosome: 6, base_position_low: 32363842, base_position_high: 32363844)
    loc_2.should == Location.new(chromosome: 6, base_position_low: 53679327, base_position_high: 53679329)
  end

end
