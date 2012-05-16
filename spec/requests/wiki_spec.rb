require 'spec_helper'

describe "wiki", type: :acceptance do

  it "GET /wiki renders Home wiki page" do
    visit "/wiki"
    page.body.should =~ /Introduction/
  end

end
