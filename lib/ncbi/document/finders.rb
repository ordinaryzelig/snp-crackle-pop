module NCBI
  module Document
    module Finders

      # Fetch data from NCBI.
      # Instantiate new object and return.
      # Record response.
      # Can fetch single id or array of ids.
      def fetch(ncbi_id_or_ids)
        ids = [ncbi_id_or_ids].flatten.map(&:to_i)
        response = perform_entrez_request(ids)
        verify_response(response)
        # Split into individual sections, parse, and instantiate objects.
        objects = new_from_splitting_xml(response.body)
        objects.each { |obj| obj.response = response }
        # Verify all found.
        ids_not_found = ids - objects.map(&:ncbi_id)
        raise NotFound.new(ids_not_found, self) if ids_not_found.any?
        if ncbi_id_or_ids.respond_to?(:each)
          objects
        else
          objects.first
        end
      rescue NCBI::XMLParseable::XMLCouldNotBeVerified
        # This might happen if ncbi_ids had the correct format, but were not found anyway.
        raise NotFound.new(ncbi_id_or_ids, self)
      rescue BadResponse
        # This could either be a badly formed request, or more likely, ncbi_ids were not valid.
        raise NotFound.new(ncbi_id_or_ids, self)
      end

      # Same as fetch and saves to database.
      def fetch!(ncbi_id_or_ids)
        object = fetch(ncbi_id_or_ids)
        [object].flatten.each(&:save!)
        object
      end

      def fetch_in_batches(batch_size, ncbi_ids)
        ncbi_ids.each_slice(batch_size).flat_map do |batch|
          fetch batch
        end
      end

      def fetch_in_batches!(batch_size, ncbi_ids)
        fetch_in_batches(batch_size, ncbi_ids).each(&:save!)
      end

      def find_all_by_unique_id_field_or_fetch_by_unique_id_field!(unique_ids)
        # Use case-insensitive regular expressions to search for strings
        mongoid_field = fields[unique_id_field.to_s]
        formatted_ids = case mongoid_field.type.name
          when 'String'
            unique_ids.map { |unique_id| Regexp.new(unique_id.to_s, true) }
          when 'Integer'
            unique_ids.map { |unique_id| unique_id.to_i }
          else
             raise "#{mongoid_field.type} not implemented"
          end
        found_locally = where(unique_id_field.in => formatted_ids)
        did_not_find_all = found_locally.count < unique_ids.size
        if did_not_find_all
          # Search for all and subtract from ids found locally.
          search_results = search_by_unique_id_field(unique_ids)
          ids_not_found_locally = search_results.map(&:ncbi_id) - found_locally.map(&:ncbi_id)
          fetch!(ids_not_found_locally)
        end
        found_locally
      end

      # Find from database.
      def find_by_ncbi_id(ncbi_id)
        where(ncbi_id: ncbi_id).first
      end

      # Find from database, if not found, fetch! it from NCBI (and store it in DB).
      def find_by_ncbi_id_or_fetch!(ncbi_id)
        find_by_ncbi_id(ncbi_id) || fetch!(ncbi_id)
      end

      # Find objects that already exist in local DB.
      # If any not found locally, fetch from NCBI.
      def find_all_by_ncbi_id_or_fetch!(ncbi_ids)
        found_locally = with_ncbi_ids(ncbi_ids)
        ids_not_found_locally = ncbi_ids.map(&:to_i) - found_locally.map(&:ncbi_id)
        fetch_in_batches!(50, ids_not_found_locally) if ids_not_found_locally.any?
        # found_locally is a Mongoid::Criteria object.
        # Since we are fetch!-ing, the new objects are being stored in the DB.
        # Criteria will query the DB each time it is accessed.
        # So now all should be "found locally".
        found_locally
      end

      # find_all_by_ncbi_id_or_fetch!, then refresh.
      def find_all_or_fetch_fresh!(ncbi_id_or_ids, refetch_if_older_than)
        objects = find_all_by_ncbi_id_or_fetch!(ncbi_id_or_ids)
        if refetch_if_older_than.present?
          refetch_if_stale!(objects, refetch_if_older_than.to_i)
        else
          objects
        end
      end

    end
  end
end
