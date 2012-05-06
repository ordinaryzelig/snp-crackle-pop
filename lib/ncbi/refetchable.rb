module NCBI
  module Refetchable

    # Update with fresh data from NCBI.
    # Delete embedded relations.
    # Assign new attributes except _id.
    # Run create callbacks.
    # Set updated_from_ncbi_at field.
    def refetch
      new_object = self.class.fetch(ncbi_id)
      delete_embedded_relations
      @response = new_object.response
      # Mongoid::Document#as_document returns all attributes including relations.
      replace_document_with new_object
      run_callbacks(:create)
      set_updated_from_ncbi_at
    end

    def refetch!
      refetch
      save!
    end

    private

    def delete_embedded_relations
      self.relations.each do |relation, attributes|
        case attributes[:relation]
        when Mongoid::Relations::Embedded::Many
          send("#{relation}").destroy_all
        when Mongoid::Relations::Embedded::One
          send("#{relation}").destroy
        end
      end
    end

    # Replace with document.
    # Assign new attributes (except _id).
    # Assign new relations.
    def replace_document_with(document)
      new_attributes = document.attributes
      new_attributes.delete('_id')
      self.attributes = new_attributes
      replace_relations document
    end

    def replace_relations(document)
      document.relations.each do |relation, relation_atts|
        send("#{relation}=", document.send(relation))
      end
    end

  end
end
