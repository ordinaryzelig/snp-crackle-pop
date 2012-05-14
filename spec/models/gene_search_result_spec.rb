require 'spec_helper'

describe Gene::SearchResult do

  context 'parses attribute' do

    before :all do
      search_results = Gene::SearchResult.all_from_fixture_file
      @object = search_results.first
    end

    it_parses_attribute :accession,          'NC_000006.11'
    it_parses_attribute :base_position_low,  30585485
    it_parses_attribute :base_position_high, 30594173
    it_parses_attribute :chromosome,         6
    it_parses_attribute :description,        'mitochondrial ribosomal protein S18B'
    it_parses_attribute :discontinued?,      false
    it_parses_attribute :location,           '6p21.3'
    it_parses_attribute :ncbi_id,            28973
    it_parses_attribute :replaced_with,      nil
    it_parses_attribute :symbol,             'MRPS18B'
    it_parses_attribute :symbols_other,      ['DADB-129D20.6', 'C6orf14', 'DKFZp564H0223', 'HSPC183', 'HumanS18a', 'MRP-S18-2', 'MRPS18-2', 'PTD017', 'S18amt']
    it_parses_attribute :other,              '28S ribosomal protein S18-2, mitochondrial|28S ribosomal protein S18b, mitochondrial|MRP-S18-b|OTTHUMP00000029404|OTTHUMP00000163697|S18mt-b|mitochondrial ribosomal protein S18-2|mrps18-b'

  end

  it 'parses attribute replaced_with and points to another gene id' do
    search_results = Gene::SearchResult.all_from_file(fixture_file('gene_search_unique_MRPS18B_esummary.xml'))
    gene_search_result = search_results.detect { |g| g.ncbi_id == 84531 }
    gene_search_result.replaced_with.should == 28973
  end

end
