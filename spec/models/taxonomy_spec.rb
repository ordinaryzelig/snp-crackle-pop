require 'spec_helper'

describe Taxonomy do

  # This tests if the actual response matches what we have stored in the fixture file.
  # If this test passes, we can mock the rest of the way.
  it 'fetches data from NCBI' do
    taxonomy = Taxonomy.fetch(9606)
    taxonomy.should match_xml_response_with(Taxonomy.fixture_file)
  end

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

  it 'should search for any name' do
    taxonomy = Taxonomy.make_from_fixture_file
    ['Homo sapiens', 'human', 'man', 'uma', 'homo'].each do |name|
      Taxonomy.search(name).should == [taxonomy]
    end
  end

end
