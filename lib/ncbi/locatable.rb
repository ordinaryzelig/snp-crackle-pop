module NCBI
  module Locatable

    def locate(terms)
      self::LocationRequest.new(terms).execute
    end

  end
end
