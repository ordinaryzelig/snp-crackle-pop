require 'spec_helper'

describe Gene::SearchResult do

  it '#parse_esummary returns array of search results' do
    search_results = Gene.search_ncbi_from_fixture_file
    search_results.size.should == 1
  end

  context 'parses attribute' do

    before :all do
      search_results = Gene.search_ncbi_from_fixture_file
      @object = search_results.first
    end

    it_parses_attribute :description,   'breast cancer 1, early onset'
    it_parses_attribute :location,      '17q21'
    it_parses_attribute :ncbi_id,       672
    it_parses_attribute :symbol,        'BRCA1'
    it_parses_attribute :symbols_other, ['BRCAI', 'BRCC1', 'BROVCA1', 'IRIS', 'PNCA4', 'PSCP', 'RNF53']
    it_parses_attribute :other,         'BRCA1/BRCA2-containing complex, subunit 1|OTTHUMP00000212143|OTTHUMP00000212147|OTTHUMP00000212148|OTTHUMP00000212149|OTTHUMP00000212150|OTTHUMP00000212151|OTTHUMP00000212155|RING finger protein 53|breast and ovarian cancer susceptibility protein 1|breast and ovarian cancer sususceptibility protein|breast cancer type 1 susceptibility protein'

  end

end
