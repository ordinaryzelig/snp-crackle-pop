require 'spec_helper'

describe 'GenomeProjects', type: :acceptance do

  it 'searches NCBI' do
    visit url(:genome_projects, :search)
    search_results = GenomeProject.search_ncbi_from_fixture_file
    GenomeProject.stubs(:search).returns(search_results)
    submit_search_for '1000 Genomes Project Pilot'
    search_results.each do |search_result|
      find_link(search_result.name)
    end
  end

  it 'displays data for single genome project' do
    genome_project = GenomeProject.make_from_fixture_file
    visit url_for(genome_project)
    page.should have_content(genome_project.sequencing_status)
  end

  it_can_be_refetched :name, 'asdf'

end
