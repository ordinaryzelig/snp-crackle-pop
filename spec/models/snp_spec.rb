require 'spec_helper'

describe Snp do

  it 'should fetch data from NCBI' do
    rs = 9268480.to_s
    snp = Snp.fetch(rs)
    snp.rs_number.should eq(rs)
  end

end
