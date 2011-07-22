require 'spec_helper'

describe GenomeProject::SearchResult do

  it '#parse_esummary returns array of search results' do
    search_results = GenomeProject.search_ncbi_from_fixture_file
    search_results.size.should == 1
  end

  context 'parses attribute' do

    before :all do
      search_results = GenomeProject.search_ncbi_from_fixture_file
      @object = search_results.first
    end

    it_parses_attribute :name,       '1000 Genomes WGS sequencing of the Kayadtha in Kolkata, India (KAK) HapMap population.'
    it_parses_attribute :ncbi_id,       60189
    it_parses_attribute :sequencing_centers, '1000 Genomes Project'

  end

end