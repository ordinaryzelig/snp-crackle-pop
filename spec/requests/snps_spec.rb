require 'spec_helper'

describe 'Snps', type: :acceptance do

  it 'can be searched by rs number' do
    snp = Snp.make_from_fixture_file
    visit search_snps_path
    search_for_rs_number snp.rs_number
    page.should have_content(snp.gene_symbol)
  end

  it 'links to gene' do
    snp = Snp.make_from_fixture_file
    visit search_snps_path
    search_for_rs_number snp.rs_number
    find_link(snp.gene_symbol)
  end

end
