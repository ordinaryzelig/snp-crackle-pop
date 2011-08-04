module TokenizerHelpers

  class << self

    # Tokenize ids from a given string.
    # Split on commas and whitespace.
    def tokenize_ids(ids_string)
      ids_string.split(/[,\s]*/)
    end

  end

end
