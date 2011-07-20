require 'spec_helper'

describe GenomeProject::SearchRequest do

  it 'performs Entrez ESearch and ESummary requests' do
    search_request = GenomeProject::SearchRequest.new(ALL: 'WGS sequencing of the Kayadtha*')
    search_request.execute
    fixture_file_content = GenomeProject::SearchRequest.fixture_file.read
    search_request.should match_xml_response_with(fixture_file_content)
  end

end
