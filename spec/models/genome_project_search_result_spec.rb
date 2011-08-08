require 'spec_helper'

describe GenomeProject::SearchResult do

  context 'parses attribute' do

    before :all do
      search_results = GenomeProject::SearchResult.all_from_fixture_file
      @object = search_results.first
    end

    it_parses_attribute :name,               '1000 Genomes Project Pilot 1 (low coverage sequencing of 180 Hapmap individuals from multiple populations.'
    it_parses_attribute :ncbi_id,            28911
    it_parses_attribute :sequencing_centers, ['1000 Genomes Project']

  end

end
