require 'spec_helper'

describe Snp do

  it 'splits XML into Rs sections' do
    fixture_file_xml_content = Snp.fixture_file.read
    Snp.split_xml(fixture_file_xml_content).first['rsId'].should == Nokogiri.XML(fixture_file_xml_content).css('Rs').first['rsId']
  end

  context 'parses attribute' do

    before :all do
      snp = Snp.from_fixture_file
      @object = snp
    end

    it_parses_attribute :ancestral_allele,       'C'
    it_parses_attribute :refSNP_alleles,         ['C', 'T']
    it_parses_attribute :chromosome,             6
    it_parses_attribute :gene_symbol,            'BTNL2'
    it_parses_attribute :het_uncertainty,        0.244
    it_parses_attribute :heterozygosity,         0.307
    it_parses_attribute :max_success_rate,       nil
    it_parses_attribute :min_success_rate,       nil
    it_parses_attribute :minor_allele,           'T'
    it_parses_attribute :minor_allele_frequency, 0.2006
    it_parses_attribute :modification_build,     132
    it_parses_attribute :modification_date,      Time.new(2011, 6, 17, 15, 29)
    it_parses_attribute :ncbi_id,                9268480
    it_parses_attribute :ncbi_gene_id,           56244
    it_parses_attribute :ncbi_taxonomy_id,       9606
    it_parses_attribute :protein_accession,      'NP_062548'
    it_parses_attribute :protein_version,        1
    it_parses_attribute :rs_number,              9268480
    it_parses_attribute :snp_class,              'snp'

  end

  it '#find_by_ncbi_id_or_fetch finds rs from database if it exists' do
    snp = Snp.make_from_fixture_file
    Snp.expects(:fetch).never
    Snp.find_by_ncbi_id_or_fetch! snp.ncbi_id
  end

  it '#find_by_ncbi_id_or_fetch fetches rs from NCBI if not found' do
    Snp.expects(:fetch!).once.returns(nil)
    Snp.find_by_ncbi_id_or_fetch! 1
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

  it 'refetches data from NCBI' do
    snp = Snp.make_from_fixture_file(het_uncertainty: 0.999, updated_from_ncbi_at: 1.year.ago, alleles: [])
    old_id = snp._id
    fake_service_with_file :EFetch, Snp.fixture_file do
      snp.refetch
    end
    snp._id.should == old_id
    snp_fixture = Snp.from_fixture_file
    snp.het_uncertainty.should == snp_fixture.het_uncertainty
    snp.alleles.should == snp_fixture.alleles
    snp.updated_from_ncbi_at_changed?.should be_true
  end

  it 'finds multiple objects that exist in local db by NCBI ids' do
    ids = [1, 2]
    ids.each { |id| Snp.make(ncbi_id: id) }
    Snp.with_ncbi_ids(ids).map(&:ncbi_id).should =~ ids
  end

  it 'fetches multiple objects that do not already exist in local DB' do
    fake_service_with_file :EFetch, fixture_file('snps_9268480_672_efetch.xml') do
      ids = [9268480, 672]
      Snp.fetch(ids).map(&:rs_number).should == ids
    end
  end

  it 'raises exception if all ids not found when fetching' do
    fake_service_with_file :EFetch, fixture_file('snp_9268480_efetch.xml') do
      lambda { Snp.fetch([9268480, 1]) }.should raise_error(Snp::NotFound)
    end
  end

  it 'finds unique identifiers' do
    identifiers = [9268480, 672]
    identifiers.each do |id|
      Snp.make_from_fixture_file(ncbi_id: id, rs_number: id)
    end
    snps = Snp.find_all_by_unique_id_field_or_fetch_by_unique_id_field!(identifiers)
    snps.map(&:ncbi_id).should == identifiers
  end

  it 'fetches unique identifiers' do
    fake_search_request fixture_file('snp_search_9268480_672_esummary.xml') do
      fake_service_with_file :EFetch, fixture_file('snps_9268480_672_efetch.xml') do
        Taxonomy.make_from_fixture_file
        identifiers = [9268480, 672]
        snps = Snp.find_all_by_unique_id_field_or_fetch_by_unique_id_field!(identifiers)
        snps.map(&:ncbi_id).should == identifiers
      end
    end
  end

end
