require 'spec_helper'

describe GenomeProject::SearchRequest do

  it 'performs Entrez ESearch and ESummary requests' do
    search_request = GenomeProject::SearchRequest.new('1000 Genomes Project Pilot')
    search_request.execute
    search_request.should match_xml_response_with(GenomeProject::SearchRequest.fixture_file)
  end

end
