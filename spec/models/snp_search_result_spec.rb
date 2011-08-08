require 'spec_helper'

describe Snp::SearchResult do

  context 'parses attribute' do

    before :all do
      search_results = Snp::SearchResult.all_from_fixture_file
      @object = search_results.first
    end

    it_parses_attribute :rs_number, 'rs672'

  end

end
