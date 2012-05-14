require 'spec_helper'

describe Snp::SearchResult do

  context 'parses attribute' do

    before :all do
      @search_results = Snp::SearchResult.all_from_fixture_file
      @object = @search_results.first
    end

    it_parses_attribute :base_position,   53679329
    it_parses_attribute :chromosome,      1
    it_parses_attribute :function_class, 'downstream-variant-500B,utr-variant-3-prime'
    it_parses_attribute :merged_with,    nil
    it_parses_attribute :rs_number,      'rs672'
    it_parses_attribute :snp_class,      'snp'

  end

  it 'parses attribute merged_with and points to another RS number' do
    search_results = Snp::SearchResult.all_from_file(fixture_file('snp_locate_chr_6_base_32363840_to_32363850_esummary.xml'))
    snp_search_result = search_results.detect { |s| s.ncbi_id == 17208804 }
    snp_search_result.discontinued?.should be_true
    snp_search_result.merged_with.should == 9268480
  end

end
