require 'spec_helper'

describe Snp do

  # This tests if the actual response matches what we have stored in the fixture file.
  # If this test passes, we can mock the rest of the way.
  it 'fetches data from NCBI' do
    rs = 9268480
    fixture_file_xml_content = fixture_file("snp_#{rs}.xml").read.chomp
    snp = Snp.fetch(rs)
    snp.response.body.chomp.should == fixture_file_xml_content
  end

  context 'parses attribute' do

    before :all do
      snp = snp_from_fixture_file
      @record = snp
    end

    it_parses_attribute :accession,          :pending
    it_parses_attribute :allele,             :pending
    it_parses_attribute :base_position,      :pending
    it_parses_attribute :chromosome,         6
    it_parses_attribute :function_class,     :pending
    it_parses_attribute :gene,               'BTNL2'
    it_parses_attribute :het_uncertainty,    0.244
    it_parses_attribute :heterozygosity,     0.307
    it_parses_attribute :max_success_rate,   nil
    it_parses_attribute :min_success_rate,   nil
    it_parses_attribute :reference_assembly, true
    it_parses_attribute :rs_number,          9268480
    it_parses_attribute :snp_class,          'snp'
    it_parses_attribute :tax_id,             9606

  end

  it '#find_by_entrez_id_or_fetch finds rs from database if it exists' do
    snp = snp_from_fixture_file
    snp.save!
    Snp.expects(:fetch).never
    Snp.find_by_entrez_id_or_fetch snp.rs_number
  end

  it '#find_by_entrez_id_or_fetch fetches rs from NCBI if not found' do
    Snp.expects(:fetch).once
    Snp.find_by_entrez_id_or_fetch 1 rescue nil
  end

  it 'should return taxonomy object for tax_id' do
    snp = snp_from_fixture_file
    taxonomy = snp.taxonomy
    taxonomy.should_not be_nil
    taxonomy.genbank_common_name.should eq('human')
    taxonomy.should eq(Taxonomy.first)
  end

end
