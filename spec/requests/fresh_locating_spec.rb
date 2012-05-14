require 'spec_helper'

describe 'fresh locating', type: :acceptance do

  it 'locates objects by location and refetches if necessary' do
    VCR.use_cassette 'locate_fresh_chromosome_6_32363843' do
      visit 'snps/locate'
      fill_in 'locations', with: '6,32363843'
      click_button 'Locate'
      csv = Snp.all.to_csv
      page.body.should == csv
    end
  end

end
