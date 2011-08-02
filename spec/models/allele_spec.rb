require 'spec_helper'

describe Allele do

  context 'parses attribute' do

    before :all do
      snp = Snp.from_fixture_file
      @object = snp.alleles.first
    end

    it_parses_attribute :base,           'A'
    it_parses_attribute :function_class, 'synonymous-codon'

  end

end
