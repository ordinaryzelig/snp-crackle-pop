require 'spec_helper'

describe Gene do

  # This tests if the actual response matches what we have stored in the fixture file.
  # If this test passes, we can mock the rest of the way.
  it 'fetches data from NCBI' do
    gene_id = 672
    fixture_file_xml_content = fixture_file("gene_#{gene_id}.xml").read.chomp
    gene = Gene.fetch(gene_id)
    gene.response.body.chomp.should == fixture_file_xml_content
  end

  context 'parses attribute' do

    before :all do
      gene = gene_from_fixture_file
      @record = gene
    end

    it_parses_attribute :diseases, ["Breast cancer", "Breast-ovarian cancer, familial, 1", "Pancreatic cancer, susceptibility to, 4"]
    it_parses_attribute :gene_id,  672

  end

end
