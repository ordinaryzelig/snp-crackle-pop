require 'spec_helper'

describe NCBI::LocationRequest do

  specify 'Model.locate locates by searching for chromosome and base positions' do
    file = fixture_file('gene_locate_chr_6_base_1000000_to_2000000_esummary.xml')
    ids = Gene::SearchResult.all_from_file(file).map(&:ncbi_id)
    fake_search_request file do
      search_results = Gene.locate(chromosome: 6, base_position_low: 1_000_000, base_position_high: 2_000_000)
      search_results.map(&:ncbi_id).should =~ ids
    end
  end

  it 'widens search of base position by +/- 1 if only 1 base position given' do
    search = Snp::LocationRequest.new(base_position_low: 10)
    search.base_position_low.should ==  9
    search.base_position_high.should == 11
  end

end
