require 'spec_helper'

describe 'Home page', type: :acceptance do

  it_can_polymorphically_search_for Snp,           search_term: '9268480', stub: false
  it_can_polymorphically_search_for Gene,          search_term: 'Human'
  it_can_polymorphically_search_for GenomeProject, search_term: '1000 Genomes Project Pilot'

end
