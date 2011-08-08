require 'spec_helper'

describe Gene do

  # This tests if the actual response matches what we have stored in the fixture file.
  # If this test passes, we can mock the rest of the way.
  it 'fetches data from NCBI' do
    fixture_file_xml_content = Gene.fixture_file.read
    gene = Gene.fetch(55245)
    gene.should match_xml_response_with(fixture_file_xml_content)
  end

  context 'parses attribute' do

    before :all do
      gene = Gene.from_fixture_file
      @object = gene
    end

    it_parses_attribute :description,           'ubiquinol-cytochrome c reductase complex chaperone'
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

  it 'assigns itself to child Snps' do
    gene_id = 1
    snp = Snp.make(ncbi_gene_id: gene_id)
    snp.gene.should be_nil
    gene = Gene.make(ncbi_id: gene_id)
    gene.assign_to_child_snps
    snp.reload.gene.should == gene
  end

  it 'searches NCBI by symbols or location' do
    gene = Gene.from_fixture_file
    ['UQCC', 'BFZB', '20q11.22'].each do |term|
      gene.should be_found_when_searching_NCBI_for(term)
    end
  end

  it_raises_error_if_ncbi_cannot_find_it

  it 'fetches multiple objects from NCBI' do
    ids = [253461, 55245]
    fixture_file_xml_content = fixture_file('genes_253461_55245_efetch.xml')
    stub_entrez_request_with_stubbed_response :EFetch, fixture_file_xml_content
    Gene.fetch(ids).map(&:ncbi_id).should == ids
  end

  it 'calculates seequence length' do
    gene = Gene.make_from_fixture_file
    gene.sequence_length.should == 109_577
  end

end
