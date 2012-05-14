require 'spec_helper'

describe NCBI::Timestamp do

  describe '#age' do

    it 'returns number of days since updated_from_ncbi_at' do
      snp = Snp.new(updated_from_ncbi_at: 2.days.ago)
      snp.age.should == 2
    end

    it 'returns 0 if updated today' do
      snp = Snp.new(updated_from_ncbi_at: Date.today)
      snp.age.should == 0
    end

  end

  specify '#older_than? returns true if object is older than given number of days' do
    gene = Gene.new(updated_from_ncbi_at: 2.days.ago)
    gene.older_than?(1).should == true
  end

end
