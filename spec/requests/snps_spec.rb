require 'spec_helper'

describe 'Snps', type: :acceptance do

  it 'can be searched by rs number' do
    snp = Snp.make_from_fixture_file
    visit SnpCracklePop.url(:snps, :index)
    search_for_rs_number snp.rs_number
    page.should have_content(snp.gene)
  end

end
