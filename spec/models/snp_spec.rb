require 'spec_helper'

describe Snp do

  # This is here just as a reminder to find an rs# that has all fields.
  # It would help to test that it all works together.
  # We can then also get rid of tests for individual fields.
  it 'should fetch data from NCBI (see note in spec)'

  it 'should fetch data from NCBI' do
    rs = 121908378
    snp = Snp.fetch(rs)
    snp.rs_number.should eq(rs)
    attributes = {
      'rs_number' => 121908378,
      'chromosome' => 7,
      'gene' => 'FOXP2',
      'tax_id' => 9606,
      #'accession' => '',
      #'function_class' => '',
      'not_reference_assembly' => true,
      'heterozygosity' => 0.0,
      'het_uncertainty' => 0.0,
      'min_success_rate' => 0.0,
      'max_success_rate' => 0.0,
      #'allele' => '',
      'snp_class' => 'snp',
      #'base_position' => '',
    }
    snp_attributes = snp.attributes
    snp_attributes.delete('_id')
    snp_attributes.should eq(attributes)
  end

  it 'fetches accession'

  it 'fetches function_class'

  it 'fetches allele'

  it 'fetches base_position'

  it 'should fetch gene' do
    rs = 121908378 # foxp2 rs no.
    snp = Snp.fetch(rs)
    snp.gene.should eq('FOXP2')
  end

  it 'should fetch reference assembly' do
    rs = 121908378
    snp = Snp.fetch(rs)
    snp.not_reference_assembly.should eq(true)
  end

  it 'should fetch SNP class' do
    rs = 121908378
    snp = Snp.fetch(rs)
    snp.snp_class.should eq('snp')
  end

  it 'should fetch heterozygosity' do
    rs = 4884357
    snp = Snp.fetch(rs)
    snp.heterozygosity.should eq(0.042)
    snp.het_uncertainty.should eq(0.139)
  end

  it 'should fetch success rate' do
    rs = 1494555
    snp = Snp.fetch(rs)
    snp.min_success_rate.should eq(95)
    snp.max_success_rate.should eq(99)
  end

  it 'should persist in the database' do
    snp = Snp.fetch! 121908378
    snp.persisted?.should be_true
  end

  it 'should set rs_number as entrez_id_field' do
    rs_number = 121908378
    snp = Snp.fetch! rs_number
    Snp.find_by_entrez_id(rs_number).should eq(snp)
  end

  it 'should find it, if it is not found, fetch it' do
    rs_number = 121908378
    fetched_snp = Snp.find_by_entrez_id_or_fetch rs_number
    fetched_snp.rs_number.should eq(rs_number)
    fetched_snp.save!
    found_snp = Snp.find_by_entrez_id_or_fetch rs_number
    found_snp.should eq(fetched_snp)
    Snp.count.should eq(1)
  end

  it 'should fetch tax_id' do
    rs_number = 4884357
    snp = Snp.fetch(rs_number)
    snp.tax_id.should eq(9606)
  end

  it 'should return taxonomy object for tax_id' do
    rs_number = 4884357
    snp = Snp.fetch(rs_number)
    taxonomy = snp.taxonomy
    taxonomy.should_not be_nil
    taxonomy.genbank_common_name.should eq('human')
    taxonomy.should eq(Taxonomy.first)
  end

end
