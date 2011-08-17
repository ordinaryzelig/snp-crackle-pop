require 'spec_helper'

describe Snp::UniqueIdSearchRequest do

  it "formats ids with 'rs' prefix" do
    fake_search_request fixture_file('snp_search_9268480_672_esummary.xml') do
      search_request = Snp::UniqueIdSearchRequest.new(['9268480', 'rs672'])
      search_results = search_request.execute
      search_results.map(&:ncbi_id).should =~ [9268480, 672]
    end
  end

end
