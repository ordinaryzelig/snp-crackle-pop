require 'spec_helper'

describe Gene::SearchRequest do

  it 'performs Entrez ESearch and ESummary requests' do
    search_request = Gene::SearchRequest.new(UID: 672)
    search_request.execute
    fixture_file_content = Gene::SearchRequest.fixture_file.read
    search_request.xml.should == fixture_file_content
  end

end
