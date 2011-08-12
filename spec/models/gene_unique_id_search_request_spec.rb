require 'spec_helper'

describe Gene::UniqueIdSearchRequest do

  it 'performs Entrez ESearch and ESummary requests' do
    search_request = Gene::UniqueIdSearchRequest.new('MRPS18B')
    search_request.execute
    search_request.should match_xml_response_with(Gene::UniqueIdSearchRequest.fixture_file)
  end

  # Perform the same search for Gene::SearchRequest and Gene::UniqueIdSearchRequest.
  # Normal search should not filter, but unique search should.
  it 'filters out discontinued genes' do
    term = 'MRPS18B'
    normal_search_request = Gene::SearchRequest.new(term)
    unique_search_request = Gene::UniqueIdSearchRequest.new(term)
    # Stub both search requests to get ESummary xml of fixture file.
    fixture_file = fixture_file('gene_search_unique_MRPS18B_esummary.xml')
    stub_entrez_request_with_stubbed_response :ESummary, fixture_file.read
    [normal_search_request, unique_search_request].each do |search_request|
      search_request.stubs(:search_for_ncbi_ids).returns(nil)
      search_request.execute
    end
    # Normal search request should not filter, but unique search request should.
    normal_search_request.results.size.should == 2
    unique_search_request.results.size.should == 1
  end

  it 'raises exception unless exactly 1 result found for each identifier' do
    search_request = Gene::UniqueIdSearchRequest.new('asdf')
    search_request.stubs(:search_for_ncbi_ids).returns(nil)
    search_request.stubs(:get_results_from_ids).returns(nil)
    search_request.stubs(:results).returns([])
    lambda { search_request.execute }.should raise_error(NCBI::UniqueIdSearchRequest::NotFound)
    stubbed_results = 2.times.map do
      r = mock
      r.stubs(:unique_identifier).returns('asdf')
      r
    end
    search_request.stubs(:results).returns(stubbed_results)
    lambda { search_request.send(:validate_results) }.should raise_error(NCBI::UniqueIdSearchRequest::NotUnique)
  end

  it 'validates results case-insensitively' do
    symbol = 'MRPS18B'.downcase
    search_request = Gene::UniqueIdSearchRequest.new(symbol)
    search_request.stubs(:results).returns(Gene::SearchResult.all_from_fixture_file[0...1])
    lambda { search_request.send(:validate_results) }.should_not raise_error
  end

end
