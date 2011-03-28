require 'spec_helper'

describe Taxonomy do

  it 'should fetch data from NCBI' do
    tax_id = 9606
    attributes = {
      'tax_id' => 9606,
      'scientific_name' => 'Homo sapiens',
      'genbank_common_name' => 'human',
      'common_name' => 'man',
    }
    tax = Taxonomy.fetch(tax_id)
    tax.tax_id.should eq(tax_id)
    tax_attributes = tax.attributes
    tax_attributes.delete('_id')
    tax_attributes.should eq(attributes)
  end

  it 'should search for any name' do
    taxonomy = Taxonomy.fetch!(9606)
    ['Homo sapiens', 'human', 'man', 'uma', 'homo'].each do |name|
      Taxonomy.search(name).should include(taxonomy)
    end
  end

end
