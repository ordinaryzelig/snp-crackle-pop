require 'spec_helper'

describe Gene::SearchRequest do

  it 'requires at least 3 characters' do
    valids = ['iri', 1, 123, '1', '-1.23']
    valids.each do |term|
      term.should be_valid_to_search(Gene)
    end
    invalids = ['ir', '']
    invalids.each do |term|
      term.should_not be_valid_to_search(Gene)
    end
  end

end
