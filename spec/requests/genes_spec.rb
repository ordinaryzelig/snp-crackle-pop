require 'spec_helper'

describe 'Genes', type: :acceptance do

  it 'can be searched by symbol' do
    gene = Gene.make_from_fixture_file
    visit url(:genes, :search)
    submit_search_for gene.symbol
    find_link(gene.symbol)
  end

  it 'displays data for single gene' do
    gene = Gene.make_from_fixture_file
    visit url_for(gene)
    page.should have_content(gene.name)
  end

end
