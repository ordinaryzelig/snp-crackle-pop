module NCBI
  module Refetchable

    # Update with fresh data from NCBI.
    def refetch
      response = self.class.send(:perform_entrez_request, ncbi_id)
      self.attributes = self.class.send(:attributes_from_xml, response.body)
      set_updated_from_ncbi_at
    end

    def refetch!
      refetch
      save!
    end

  end
end
