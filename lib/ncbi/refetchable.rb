module NCBI
  module Refetchable

    # Update with fresh data from NCBI.
    # Assign new attributes except _id.
    def refetch
      new_object = self.class.fetch(ncbi_id)
      @response = new_object.response
      # Mongoid::Document#as_document returns all attributes including relations.
      new_attributes = new_object.as_document
      new_attributes.delete('_id')
      self.attributes = new_attributes
      set_updated_from_ncbi_at
    end

    def refetch!
      refetch
      save!
    end

  end
end
