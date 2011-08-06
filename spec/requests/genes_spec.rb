require 'spec_helper'

describe 'Genes', type: :acceptance do

  it 'searches NCBI' do
    visit url(:genes, :search)
    search_results = Gene::SearchResult.all_from_fixture_file
    Gene.stubs(:search).returns(search_results)
    submit_search_for 'human'
    ['MRPS18B', 'MRPS18A'].each do |symbol|
      find_link(symbol)
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
