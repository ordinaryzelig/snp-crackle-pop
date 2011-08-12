require 'spec_helper'

describe Snp::UniqueIdSearchRequest do

  it "formats ids with 'rs' prefix" do
    search_request = Snp::UniqueIdSearchRequest.new(['9268480', 'rs672'])
    search_request.execute
    search_request.should match_xml_response_with(fixture_file('snp_search_9268480_672_esummary.xml'))
  end

end
