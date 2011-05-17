require 'spec_helper'

describe 'Snps', type: :acceptance do

  it 'can be searched by rs number' do
    snp = Snp.make_from_fixture_file
    visit url(:snps, :search)
    submit_search_for snp.rs_number
    page.should have_content(snp.gene_symbol)
  end

  it 'links to gene' do
    snp = Snp.make_from_fixture_file
    visit url_for(snp)
    find_link(snp.gene_symbol)
  end

end
