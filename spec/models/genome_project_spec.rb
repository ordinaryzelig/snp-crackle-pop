require 'spec_helper'

describe GenomeProject do

  it 'fetches data from NCBI' do
    genome_project_id = 28911
    genome_project = GenomeProject.fetch(genome_project_id)
    fixture_file_xml_content = fixture_file("genome_project_#{genome_project_id}.xml").read
    genome_project.should match_xml_response_with(fixture_file_xml_content)
  end

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

  it 'searches local db by name or sequencing centers' do
    genome_project = GenomeProject.make_from_fixture_file(sequencing_centers: ['OMRF'])
    ['1000 Genomes', 'genomes', 'OMRF', 'omr'].each do |term|
      genome_project.should be_found_when_searching_locally_for(term)
    end
  end

  it 'searches NCBI by any field' do
    genome_project = GenomeProject.make_from_fixture_file(sequencing_centers: ['OMRF'])
    genome_project.should be_found_when_searching_NCBI_for('1000 Genomes Project')
  end

end
