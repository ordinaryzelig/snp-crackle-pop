module NCBI
  module HasTaxonomy

    def has_taxonomy
      belongs_to :taxonomy
      before_create :assign_taxonomy, unless: 'taxonomy_id || taxonomy'
      include InstanceMethods
    end

    module InstanceMethods

      private

      def assign_taxonomy
        self.taxonomy = Taxonomy.find_by_ncbi_id_or_fetch! self.ncbi_taxonomy_id
      end

    end

  end
end
