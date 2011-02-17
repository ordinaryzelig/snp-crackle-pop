require 'spec_helper'

describe Snp do

  it 'should fetch data from NCBI and store it in the DB' do
    rs = 9268480
    snp = Snp.fetch!(rs)
    snp.rs_number.should eq(rs)
    snp.should_not be_new_record
  end

  it 'should find it, if it is not found, fetch it'

end
