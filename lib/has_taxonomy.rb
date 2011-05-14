# Pseudo association for taxonomy.
# Model that calls has_taxonomy(xml_proc) will have taxonomy method
# that finds or fetches taxonomy based on assumed tax_id field.
module HasTaxonomy

  def has_taxonomy
    include InstanceMethods
  end

  module InstanceMethods

    # Thought about using referenced_in/references_many, but
    # then we'd have to store mongo ids and that seems like overkill.
    def taxonomy
      Taxonomy.find_by_entrez_id_or_fetch!(tax_id)
    end

  end

end
