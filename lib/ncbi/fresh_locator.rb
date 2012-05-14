# Given array of chromosome/base position locations, search for them.
# For each search result, find or fetch.
# Given threshold (num days), refetch an object if object is older than threshold.
module NCBI
  module FreshLocator

    # Locate then find_or_fetch_fresh!.
    def locate_fresh(locations, refetch_if_older_than = nil)
      search_results = locate_in_batches(100, locations)
      search_results.reject!(&:discontinued?)
      return [] if search_results.empty?
      ncbi_ids = search_results.map(&:ncbi_id)
      ncbi_ids.uniq!
      find_all_or_fetch_fresh!(ncbi_ids, refetch_if_older_than)
    end

  end
end
