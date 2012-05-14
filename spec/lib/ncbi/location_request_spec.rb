require 'spec_helper'

describe NCBI::LocationRequest do

  describe 'Model.locate' do

    it 'locates by searching for chromosome and base positions' do
      file = fixture_file('gene_locate_chr_6_base_1000000_to_2000000_esummary.xml')
      ids = Gene::SearchResult.all_from_file(file).map(&:ncbi_id)
      location = Location.new(chromosome: 6, base_position_low: 1_000_000, base_position_high: 2_000_000)
      fake_search_request file do
        search_results = Gene.locate(location)
        search_results.map(&:ncbi_id).should =~ ids
      end
    end

    it 'locates multiple locations' do
      VCR.use_cassette 'snp_locate_multiple' do
        locations = [
          Location.new(chromosome: 6, base_position_low: 32364355),
          Location.new(chromosome: 6, base_position_low: 32363843),
        ]
        search_results = Snp.locate(locations)
        rs_ids = [
          9268480,
          9268481,
          17208804,
          17423795,
          57538739,
          114338049,
          116165642,
          117100552,
          117919974,
        ]
        search_results.map(&:ncbi_id).should == rs_ids
      end
    end

  end

end
