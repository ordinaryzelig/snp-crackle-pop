require 'spec_helper'

describe Gene do

  # This tests if the actual response matches what we have stored in the fixture file.
  # If this test passes, we can mock the rest of the way.
  it 'fetches data from NCBI' do
    gene_id = 672
    fixture_file_xml_content = fixture_file("gene_#{gene_id}.xml").read.chomp
    gene = Gene.fetch(gene_id)
    begin
      timeout(2.seconds) { gene.response.body.chomp.should == fixture_file_xml_content }
    rescue Timeout::Error
      puts gene.response.body
      fail 'File comparison taking too long. Most likely because files do not match.'
    end
  end

  context 'parses attribute' do

    before :all do
      gene = Gene.from_fixture_file
      @record = gene
    end

    it_parses_attribute :accessions,       :pending
    it_parses_attribute :diseases,         ["Breast cancer", "Breast-ovarian cancer, familial, 1", "Pancreatic cancer, susceptibility to, 4"]
    it_parses_attribute :exon_count,       :pending
    it_parses_attribute :group,            :pending
    it_parses_attribute :length,           :pending
    it_parses_attribute :location,         '17q21'
    it_parses_attribute :name,             'breast cancer 1, early onset'
    it_parses_attribute :ncbi_id,          672
    it_parses_attribute :ncbi_taxonomy_id, 9606
    it_parses_attribute :mim,              113705
    it_parses_attribute :protein_name,     'breast cancer type 1 susceptibility protein'
    it_parses_attribute :symbol,           'BRCA1'
    it_parses_attribute :symbols_other,    ['IRIS', 'PSCP', 'BRCAI', 'BRCC1', 'PNCA4', 'RNF53', 'BROVCA1']

  end

  it 'assigns itself to child Snps' do
    gene_id = 1
    snp = Snp.make(ncbi_gene_id: gene_id)
    snp.gene.should be_nil
    gene = Gene.make(ncbi_id: gene_id)
    gene.assign_to_child_snps
    snp.reload.gene.should == gene
  end

  it 'can be searched by symbols, name, location, or protein name' do
    gene = Gene.make_from_fixture_file
    ['BRCA1', 'br', 'IRIS', 'ir', 'breast cancer', 'susceptibility', 'early onset', '17q21', '17'].each do |term|
      gene.should be_found_when_searching_for(term)
    end
  end

  it_raises_error_if_NCBI_cannot_find_it

end
