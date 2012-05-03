require 'spec_helper'

describe Gene do

  context 'parses attribute' do

    before :all do
      gene = Gene.from_fixture_file
      @object = gene
    end

    it_parses_attribute :description,           'ubiquinol-cytochrome c reductase complex chaperone'
    it_parses_attribute :discontinued,          false
    it_parses_attribute :diseases,               ["A genome-wide association study in 19 633 Japanese subjects identified LHX3-QSOX2 and IGF1 as adult height loci.",
                                                  "Common variants in the GDF5-UQCC region are associated with variation in human height.",
                                                  "Genome-wide association analysis identifies 20 loci that influence adult height.",
                                                  "Identification of ten loci associated with height highlights new biological pathways in human growth.",
                                                  "Many sequence variants affecting diversity of adult human height.",
                                                  "Meta-analysis of genome-wide scans for human adult stature identifies novel Loci and associations with measures of skeletal frame size.",
                                                  "Stature quantitative trait locus 14",
                                                 ]
    it_parses_attribute :location,               '20q11.22'
    it_parses_attribute :ncbi_id,                55245
    it_parses_attribute :ncbi_taxonomy_id,       9606
    it_parses_attribute :mim,                    611797
    it_parses_attribute :protein_name,           'ubiquinol-cytochrome c reductase complex chaperone CBP3 homolog'
    it_parses_attribute :sequence_accession,     'NC_000020'
    it_parses_attribute :sequence_interval_from, 33890368
    it_parses_attribute :sequence_interval_to,   33999944
    it_parses_attribute :sequence_version,       10
    it_parses_attribute :symbol,                 'UQCC'
    it_parses_attribute :symbols_other,          ['BFZB', 'CBP3', 'C20orf44', 'MGC104353', 'MGC141902']

  end

  it 'parses attribute discontinued' do
    gene = Gene.new_from_xml(fixture_file('gene_84531_efetch.xml').read)
    gene.discontinued.should == true
  end

  it 'searches NCBI by symbols or location' do
    gene = Gene.from_fixture_file
    ['UQCC', 'BFZB', '20q11.22'].each do |term|
      fake_search_request fixture_file("gene_search_#{term}_esummary.xml") do
        gene.should be_found_when_searching_NCBI_for(term)
      end
    end
  end

  it_raises_error_if_ncbi_cannot_find_it

  it 'fetches multiple objects from NCBI' do
    ids = [253461, 55245]
    fake_service_with_file :EFetch, fixture_file('genes_253461_55245_efetch.xml') do
      Gene.fetch(ids).map(&:ncbi_id).should == ids
    end
  end

  it 'calculates seequence length' do
    gene = Gene.make_from_fixture_file
    gene.sequence_length.should == 109_577
  end

  it 'fetches by unique identifier' do
    fake_search_request fixture_file('gene_search_unique_MRPS18B_esummary.xml') do
      fake_service_with_file :EFetch, fixture_file('gene_28973_efetch.xml') do
        Taxonomy.make_from_fixture_file
        identifier = 'MRPS18B'
        gene = Gene.find_all_by_unique_id_field_or_fetch_by_unique_id_field!([identifier]).first
        gene.symbol.should == identifier
      end
    end
  end

  it 'finds by unique identifiers' do
    identifiers = ['abc', 'xyz']
    identifiers.each do |symbol|
      Gene.make_from_fixture_file symbol: symbol
    end
    genes = Gene.find_all_by_unique_id_field_or_fetch_by_unique_id_field!(identifiers)
    genes.map(&:symbol).should == identifiers
  end

  it 'locates by searching for chromosome and base positions' do
    file = fixture_file('gene_locate_chr_6_base_1000000_to_2000000_esummary.xml')
    ids = Gene::SearchResult.all_from_file(file).map(&:ncbi_id)
    fake_search_request file do
      search_results = Gene.locate(chromosome: 6, base_position_low: 1_000_000, base_position_high: 2_000_000)
      search_results.map(&:ncbi_id).should =~ ids
    end
  end

end
