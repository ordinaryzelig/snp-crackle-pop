module NCBI
  module Refetchable

    # Get updated data from NCBI.
    # Destroy existing objects, fetch! them again.
    # NOTE The _id field is not preserved!
    def refetch!(ncbi_id_or_ids)
      where(ncbi_id: ncbi_id_or_ids).destroy_all
      if ncbi_id_or_ids.respond_to?(:each)
        fetch_in_batches!(50, ncbi_id_or_ids)
      else
        fetch!(ncbi_id_or_ids)
      end
    end

    # Determine which objects's data are older than threshold.
    # Refetch stale objects.
    # Return all.
    def refetch_if_stale!(objects, refetch_if_older_than)
      grouped = objects.group_by { |objects| objects.older_than?(refetch_if_older_than) }
      grouped.default = []
      fresh_objects      = grouped[false]
      objects_to_refetch = grouped[true]
      if objects_to_refetch.any?
        objects_to_refetch = refetch!(objects_to_refetch.map(&:ncbi_id)) 
      end
      fresh_objects + objects_to_refetch
    end

  end
end
