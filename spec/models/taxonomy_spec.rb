require 'spec_helper'

describe Taxonomy do

  context 'parses attribute' do

    before :all do
      taxonomy = Taxonomy.from_fixture_file
      @object = taxonomy
    end

    it_parses_attribute :common_name,         'man'
    it_parses_attribute :genbank_common_name, 'human'
    it_parses_attribute :ncbi_id,             9606
    it_parses_attribute :scientific_name,     'Homo sapiens'

  end

end
