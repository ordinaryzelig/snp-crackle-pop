require 'spec_helper'

describe GenomeProject do

  context 'parses attribute' do

    before :all do
      genome_project = GenomeProject.from_fixture_file
      @object = genome_project
    end

    it_parses_attribute :name,               '1000 Genomes Project Pilot 1 (low coverage sequencing of 180 Hapmap individuals from multiple populations.'
    it_parses_attribute :ncbi_id,            28911
    it_parses_attribute :sequencing_centers, ['1000 Genomes Project']
    it_parses_attribute :sequencing_status,  'inprogress'
    it_parses_attribute :ncbi_taxonomy_id,   9606

  end

  it_raises_error_if_ncbi_cannot_find_it

  it 'searches NCBI by any field' do
    fake_search_request fixture_file('genome_project_search_1000_Genomes_Project_Pliot_esummary.xml') do
      Taxonomy.make_from_fixture_file
      genome_project = GenomeProject.make_from_fixture_file(sequencing_centers: ['OMRF'])
      genome_project.should be_found_when_searching_NCBI_for('1000 Genomes Project')
    end
  end

end
