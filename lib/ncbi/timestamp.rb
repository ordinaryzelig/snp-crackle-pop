# Track when the last time the document was updated with data from NCBI.
# Adds updated_from_ncbi_at field and callback to set it when refetch() is called.
# calling refetch() will update the field.

module NCBI
  module Timestamp

    def self.included(base)
      base.extend ClassMethods
    end

    # Days since updated_from_ncbi_at.
    def age
      (Date.today - updated_from_ncbi_at.to_date).to_i
    end

    def older_than?(days)
      age > days
    end

    private

    def set_updated_from_ncbi_at
      self.updated_from_ncbi_at = Time.zone.now.utc
    end

    module ClassMethods

      def ncbi_timestamp_field
        field :updated_from_ncbi_at, type: Time
        before_create :set_updated_from_ncbi_at, unless: :updated_from_ncbi_at?
      end

    end

  end
end
