require 'spec_helper'

describe TokenizerHelpers do

  it 'tokenizes ids splitting on commas and whitespace' do
    ids = ['11', '22', '33']
    [
      '11 22 33',
      '11,22,33',
      '11,  22,    33',
      "11,\n22,\n,\n33,\n"
    ].each do |ids_string|
      TokenizerHelpers.tokenize_ids(ids_string).should == ids
    end
  end

end
