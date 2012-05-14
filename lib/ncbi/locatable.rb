module NCBI
  module Locatable

    def locate(locations)
      self::LocationRequest.new(locations).execute
    end

    def locate_in_batches(batch_size, locations)
      locations.each_slice(batch_size).flat_map do |batch|
        locate batch
      end
    end

  end
end
