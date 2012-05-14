require 'spec_helper'

describe 'GenomeProjects', type: :acceptance do

  it 'searches NCBI' do
    visit url(:genome_projects, :search)
    file = GenomeProject::SearchResult.fixture_file
    search_results = GenomeProject::SearchResult.all_from_file(file)
    fake_search_request file do
      submit_search_for '1000 Genomes Project Pilot'
    end
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

  specify 'GET genome_projects/show refetches if older than 0 days' do
    genome_project = GenomeProject.make_from_fixture_file(updated_from_ncbi_at: 1.day.ago)
    GenomeProject.expects(:refetch_if_stale!).with([genome_project], 0).returns([genome_project])
    visit url(:genome_projects, :show, id: genome_project.ncbi_id)
  end

end
