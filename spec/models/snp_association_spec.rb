require 'spec_helper'

describe SnpAssociation do

  describe '.fetch' do

    it 'returns SnpAssociation object if association is found' do
      VCR.use_cassette 'snp_association_6859219' do
        snp_association = SnpAssociation.fetch(6859219)
        snp_association.should be_kind_of(SnpAssociation)
      end
    end

    it 'returns nil if associatio not found' do
      VCR.use_cassette 'snp_association_672' do
        snp_association = SnpAssociation.fetch(672)
        snp_association.should be_nil
      end
    end

  end

  describe '.request' do

    it 'sends request to NCBI' do
      VCR.use_cassette 'snp_association_6859219' do
        response = SnpAssociation.send :request, 6859219
        expected = fixture_file_content('snp_association_6859219.txt')
        response.body.should == expected
      end
    end

    it 'returns timeout message if SNP does not have association' do
      VCR.use_cassette 'snp_association_672' do
        response = SnpAssociation.send :request, 672
        expected = fixture_file_content('snp_association_672.txt')
        response.body.should == expected
      end
    end

  end

  describe '.parse' do

    it 'returns the SNP rs number' do
      text = fixture_file_content('snp_association_6859219.txt')
      rs_number = SnpAssociation.send :parse, text
      rs_number.should == '6859219'
    end

    it 'returns false if no SNP association not found' do
      text = fixture_file_content('snp_association_672.txt')
      SnpAssociation.send(:parse, text).should == false
    end

  end

end
