require 'spec_helper'

describe Taxonomy do

  # This tests if the actual response matches what we have stored in the fixture file.
  # If this test passes, we can mock the rest of the way.
  it 'fetches data from NCBI' do
    tax_id = 9606
    fixture_file_xml_content = fixture_file("taxonomy_#{tax_id}.xml").read.chomp
    taxonomy = Taxonomy.fetch(tax_id)
    taxonomy.response.body.chomp.should == fixture_file_xml_content
  end

  context 'parses attribute' do

    before :all do
      taxonomy = Taxonomy.from_fixture_file
      @record = taxonomy
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
