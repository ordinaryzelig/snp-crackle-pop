require 'spec_helper'

describe 'Snps', type: :acceptance do

  it 'can be searched by RS number' do
    snp = Snp.make_from_fixture_file
    visit url(:snps, :search)
    submit_search_for snp.rs_number
    page.should have_content(snp.gene_symbol)
  end

  it 'searches NCBI by chromosome and base position' do
    terms = {
      chromosome:         '6',
      base_position_low:  32_363_840,
      base_position_high: 32_363_850,
    }
    search_results = Snp::SearchResult.all_from_file(fixture_file('snp_locate_chr_6_base_32363840_to_32363850_esummary.xml'))
    Snp.stubs(:locate).returns(search_results)
    visit url(:snps, :search)
    submit_location_search_for terms
    search_results.should be_found_on_search_results_page_when_looking_for(:rs_number)
  end

  it "can be searched by rs number with 'rs' at front" do
    snp = Snp.make_from_fixture_file
    visit url(:snps, :search)
    submit_search_for "rs#{snp.rs_number}"
    page.should have_content(snp.gene_symbol)
  end

  it 'links to gene' do
    snp = Snp.make_from_fixture_file
    visit url_for(snp)
    find_link(snp.gene_symbol)
  end

  it_can_be_refetched :het_uncertainty, 0.999

  it_can_download_csv_of_list_of_ncbi_ids

end
