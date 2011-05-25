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
      snp = Snp.from_fixture_file
      @record = snp
    end

    it_parses_attribute :accession,          :pending
    it_parses_attribute :ancestral_allele,   'C'
    it_parses_attribute :base_position,      33930588
    it_parses_attribute :chromosome,         6
    it_parses_attribute :gene_symbol,        'BTNL2'
    it_parses_attribute :het_uncertainty,    0.244
    it_parses_attribute :heterozygosity,     0.307
    it_parses_attribute :max_success_rate,   nil
    it_parses_attribute :min_success_rate,   nil
    it_parses_attribute :modification_build, 132
    it_parses_attribute :modification_date,  Time.new(2011, 1, 11, 17, 13)
    it_parses_attribute :ncbi_id,            9268480
    it_parses_attribute :ncbi_gene_id,       56244
    it_parses_attribute :ncbi_taxonomy_id,   9606
    it_parses_attribute :reference_assembly, true
    it_parses_attribute :rs_number,          9268480
    it_parses_attribute :snp_class,          'snp'

  end

  it '#find_by_ncbi_id_or_fetch finds rs from database if it exists' do
    snp = Snp.from_fixture_file
    snp.save!
    Snp.expects(:fetch).never
    Snp.find_by_ncbi_id_or_fetch! snp.ncbi_id
  end

  it '#find_by_ncbi_id_or_fetch fetches rs from NCBI if not found' do
    Snp.expects(:fetch).once
    Snp.find_by_ncbi_id_or_fetch! 1 rescue nil
  end

  it 'assigns existing gene after creation' do
    gene_id = 1
    gene = Gene.make(ncbi_id: gene_id)
    snp = Snp.make(ncbi_gene_id: gene_id)
    snp.gene.should == gene
  end

  it 'assigns taxonomy after creation' do
    snp = Snp.make_from_fixture_file
    Taxonomy.count.should == 1
    snp.taxonomy.should == Taxonomy.first
  end

  it_raises_error_if_ncbi_cannot_find_it

  it 'can refetch data from NCBI' do
    snp = Snp.make_from_fixture_file(het_uncertainty: 0.999, updated_from_ncbi_at: 1.year.ago)
    stub_entrez_request_with_contents_of_fixture_file Snp
    snp.refetch
    snp.het_uncertainty.should == Snp.from_fixture_file.het_uncertainty
    snp.updated_from_ncbi_at_changed?.should be_true
  end

  it 'has 2 alleles' do
    snp = Snp.make_from_fixture_file
    snp.alleles.first.should have_attributes({
      base: 'A',
      function_class: 'coding-synonymous'
    })
    snp.alleles.last.should have_attributes({
      base: 'G',
      function_class: 'reference'
    })
    snp.alleles.each do |allele|
      allele.should be_persisted
    end
  end

  it 'accepts nested attributes for existing alleles and updates them' do
    snp = Snp.make_from_fixture_file
    # Construct hash for accepts_nested_attributes_for.
    # Set bases to 0 and 1.
    new_attributes = snp.alleles.each_with_index.inject({}) do |attributes, (allele, i)|
      attributes[i] = {}
      attributes[i][:base] = i
      attributes
    end
    snp.reload
    snp.alleles_attributes = new_attributes
    snp.alleles.map(&:base).should == ['0', '1']
    # function_class should still be there.
    snp.alleles.map(&:function_class).compact.should be_present
  end

end
