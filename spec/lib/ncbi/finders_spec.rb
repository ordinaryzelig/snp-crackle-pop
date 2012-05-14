require 'spec_helper'

describe NCBI::Document::Finders do

  describe '.find_or_fetch_fresh!' do

    it 'finds or fetches objects by ncbi_id' do
      Gene.expects(:find_all_by_ncbi_id_or_fetch!).returns([])
      Gene.find_all_or_fetch_fresh!([], 0)
    end

    it 'refetches if objects are stale' do
      stale_snp = Snp.new(updated_from_ncbi_at: 1.year.ago)
      Snp.stubs(:find_all_by_ncbi_id_or_fetch!).returns([stale_snp])
      Snp.expects(:refetch_if_stale!).with([stale_snp], 0)
      Snp.find_all_or_fetch_fresh!([1], 0)
    end

  end

  describe '.find_by_ncbi_id_or_fetch!' do

    it 'does not fetch if found in local db' do
      snp = Snp.make_from_fixture_file
      Snp.expects(:fetch!).never
      Snp.find_by_ncbi_id_or_fetch!(snp.ncbi_id)
    end

  end

  describe '.find_all_by_ncbi_id_or_fetch!' do

    it 'does not fetch if found in local db' do
      snp = Snp.make_from_fixture_file
      Snp.expects(:fetch!).never
      Snp.find_all_by_ncbi_id_or_fetch!([snp.ncbi_id.to_s])
    end

  end

  specify '.fetch_in_batches fetches in smaller groups' do
    ids = (1..150).to_a
    Snp.expects(:fetch).with((1..100).to_a).returns([1, 2, 3])
    Snp.expects(:fetch).with((101..150).to_a).returns([4, 5, 6])
    fetched = Snp.fetch_in_batches(100, ids)
    fetched.should == [1, 2, 3, 4, 5, 6]
  end

end
