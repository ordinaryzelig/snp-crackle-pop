require 'spec_helper'

describe 'Genes', type: :acceptance do

  it 'searches NCBI by symbol, name, protein, or location' do
    visit url(:genes, :search)
    search_results = Gene::SearchResult.all_from_fixture_file
    Gene.stubs(:search).returns(search_results)
    submit_search_for 'human'
    ['MRPS18B', 'MRPS18A'].each do |symbol|
      find_link(symbol)
    end
  end

  it 'searches NCBI by chromosome and base position' do
    terms = {
      chromosome:         '6',
      base_position_low:  1_000_000,
      base_position_high: 2_000_000,
    }
    search_results = Gene::SearchResult.all_from_file(fixture_file('gene_locate_chr_6_base_1000000_to_2000000_esummary.xml'))
    Gene.stubs(:locate).returns(search_results)
    visit url(:genes, :search)
    submit_location_search_for terms
    search_results.each do |search_result|
      find_link(search_result.symbol)
    end
  end

  it 'fetches data from search result' do
    visit url(:genes, :search)
    gene = Gene.from_fixture_file
    submit_search_for gene.symbol
    click_link(gene.symbol)
    current_path.should == url_for(gene)
    page.should have_content(gene.description)
  end

  it 'displays data for single gene' do
    gene = Gene.make_from_fixture_file
    visit url_for(gene)
    page.should have_content(gene.name)
  end

  it_can_be_refetched :symbol, 'asdf'

  it_can_download_csv_of_list_of_ncbi_ids

end
