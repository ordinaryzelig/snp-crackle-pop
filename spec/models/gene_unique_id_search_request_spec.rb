require 'spec_helper'

describe Gene::UniqueIdSearchRequest do

  it 'filters out discontinued genes' do
    unique_search_request = Gene::UniqueIdSearchRequest.new('MRPS18B')
    # Fixture file has 2 results, 1 is discontinued, so we should only get 1 result.
    fixture_file = fixture_file('gene_search_unique_MRPS18B_esummary.xml')
    fake_search_request fixture_file do
      unique_search_request.execute
    end
    unique_search_request.results.size.should == 1
  end

  it 'raises exception if no results found' do
    fake_search_request fixture_file('empty_esummary.xml') do
      search_request = Gene::UniqueIdSearchRequest.new('asdf')
      lambda { search_request.execute }.should raise_error(NCBI::UniqueIdSearchRequest::NotFound)
    end
  end

  it 'raises exception if more than 1 result found for identifier' do
    identifier = 'MRPS18B'
    search_request = Gene::UniqueIdSearchRequest.new(identifier)
    fake_search_request fixture_file('gene_search_human_esummary.xml') do
      search_request.execute
    end
    # Stub results so they all return the same unique identifier.
    search_request.results.map do |r|
      r.stubs(:unique_identifier).returns(identifier)
    end
    lambda { search_request.send(:validate_results) }.should raise_error(NCBI::UniqueIdSearchRequest::NotUnique)
  end

  it 'validates results case-insensitively' do
    symbol = 'MRPS18B'.downcase
    search_request = Gene::UniqueIdSearchRequest.new(symbol)
    search_request.stubs(:results).returns(Gene::SearchResult.all_from_fixture_file[0, 1])
    lambda { search_request.send(:validate_results) }.should_not raise_error
  end

end
