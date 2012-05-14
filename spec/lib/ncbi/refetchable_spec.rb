require 'spec_helper'

describe NCBI::Refetchable do

  describe '.refetch!' do

    it 'destroys existing object and replaces them with fetch!' do
      snp = Snp.make_from_fixture_file
      Snp.expects(:fetch).with([snp.rs_number]).returns(snp.clone)
      Snp.refetch!([snp.ncbi_id])
      proc { snp.reload }.should raise_error(Mongoid::Errors::DocumentNotFound)
      Snp.find_by_ncbi_id(snp.ncbi_id).should_not be_nil
    end

  end

  describe '.refetch_if_stale!' do

    it 'refetches given objects if they are stale' do
      fresh_snp = Snp.new(ncbi_id: 1, updated_from_ncbi_at: DateTime.now)
      stale_snp = Snp.new(ncbi_id: 2, updated_from_ncbi_at: 1.year.ago)
      Snp.expects(:refetch!).with([2]).returns([:refetched])
      snps = Snp.refetch_if_stale!([fresh_snp, stale_snp], 1)
      snps.should == [fresh_snp, :refetched]
    end

    it 'doesn not refetch if none stale' do
      fresh_snp = Snp.new(ncbi_id: 1, updated_from_ncbi_at: DateTime.now)
      Snp.expects(:refetch!).never
      Snp.refetch_if_stale!([fresh_snp], 1)
    end

  end

end
