require 'spec_helper'

describe 'Home page', type: :acceptance do

  it_can_polymorphically_search_for Snp,           with: :rs_number, finding: :gene_symbol
  it_can_polymorphically_search_for Gene,          with: :symbol,    finding: :name
  it_can_polymorphically_search_for GenomeProject, with: :name,      finding: :name

end
