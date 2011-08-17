require 'spec_helper'

describe 'Genes', type: :acceptance do

  it 'searches NCBI by symbol, name, protein, or location' do
    visit url(:genes, :search)
    fake_search_request Gene::SearchResult.fixture_file do
      submit_search_for 'human'
    end
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
    visit url(:genes, :search)
    file = fixture_file('gene_locate_chr_6_base_1000000_to_2000000_esummary.xml')
    fake_search_request file do
      submit_location_search_for terms
    end
    search_results = Gene::SearchResult.all_from_file(file)
    search_results.should be_found_on_search_results_page_when_looking_for(:symbol)
  end

  it 'fetches data from search result' do
    visit url(:genes, :search)
    gene = Gene.from_fixture_file
    Taxonomy.make_from_fixture_file
    fake_search_request fixture_file('gene_search_UQCC_esummary.xml') do
      submit_search_for gene.symbol
    end
    fake_service_with_file :EFetch, fixture_file('gene_55245_efetch.xml') do
      click_link(gene.symbol)
    end
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
