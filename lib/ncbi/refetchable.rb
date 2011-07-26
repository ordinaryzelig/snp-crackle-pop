module NCBI
  module Refetchable

    # Update with fresh data from NCBI.
    # Assign new attributes except _id.
    def refetch
      new_object = self.class.fetch(ncbi_id)
      new_attributes = new_object.attributes
      new_attributes.delete(:_id)
      self.attributes = new_attributes
      set_updated_from_ncbi_at
    end

    def refetch!
      refetch
      save!
    end

  end
end
