require 'spec_helper'

describe Assembly do

  context 'parses attributes' do

    before :all do
      snp = Snp.from_fixture_file
      @object = snp.assemblies[1]
    end

    it_parses_attribute :db_snp_build,  132
    it_parses_attribute :genome_build,  37.1
    it_parses_attribute :group_label,   'GRCh37'
    it_parses_attribute :current,       true
    it_parses_attribute :reference,     true
    it_parses_attribute :base_position, 32363843

  end

end
