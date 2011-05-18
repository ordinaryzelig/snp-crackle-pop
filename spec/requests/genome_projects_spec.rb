require 'spec_helper'

describe 'GenomeProjects', type: :acceptance do

  it 'can be searched' do
    genome_project = GenomeProject.make_from_fixture_file
    visit url(:genome_projects, :search)
    submit_search_for genome_project.name
    find_link(genome_project.name)
  end

  it 'displays data for single genome project' do
    genome_project = GenomeProject.make_from_fixture_file
    visit url_for(genome_project)
    page.should have_content(genome_project.sequencing_status)
  end

  it_can_be_refetched :name, 'asdf'

end
