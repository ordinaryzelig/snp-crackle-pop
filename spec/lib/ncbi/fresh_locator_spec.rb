require 'spec_helper'

describe NCBI::FreshLocator do

  describe 'Model.locate_fresh' do

    it 'rejects discontinued objects' do
      search_result = Snp::SearchResult.new(merged_with: 'borg')
      Snp.expects(:locate_in_batches).returns([search_result])
      Snp.locate_fresh(1).should be_empty
    end

    it 'refetches if any objects are stale' do
      # Setup.
      ncbi_id = 1
      search_result = Snp::SearchResult.new(ncbi_id: ncbi_id)
      Snp.stubs(:locate_in_batches).returns([search_result])
      stale_snp = Snp.new(ncbi_id: ncbi_id, updated_from_ncbi_at: 1.year.ago)
      Snp.stubs(:find_all_by_ncbi_id_or_fetch!).returns([stale_snp])
      # Test.
      Snp.expects(:refetch_if_stale!).with([stale_snp], 1)
      Snp.locate_fresh([], 1)
    end

  end

end
