# Track when the last time the document was updated with data from NCBI.
# Adds updated_from_NCBI_at field and callback to set it when refetch() is called.
module NCBITimestamp

  def self.included(base)
    base.extend ClassMethods
    base.instance_eval do
      attr_accessor :fetched # Set in NCBIRecord#refetch().
      before_create :set_updated_from_NCBI_at, unless: :updated_from_NCBI_at?
    end
  end

  private

  def set_updated_from_NCBI_at
    self.updated_from_NCBI_at = Time.now.utc
  end

  module ClassMethods

    def ncbi_timestamp_field
      field :updated_from_NCBI_at, type: Time
    end

  end

end
