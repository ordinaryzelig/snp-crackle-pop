require 'spec_helper'

describe TokenizerHelpers do

  it 'tokenizes ids splitting on commas and whitespace' do
    ids = %w{1 2 3}
    ['1 2 3', '1,2,3', '1, 2, 3', "1,\n2,\n,\n3,\n"].each do |ids_string|
      TokenizerHelpers.tokenize_ids(ids_string).should == ids
    end
  end

end
