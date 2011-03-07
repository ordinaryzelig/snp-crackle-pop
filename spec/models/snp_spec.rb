require 'spec_helper'

describe Snp do

  it 'should fetch data from NCBI' do
    rs = 121908378 #9268480 # random rs no.
    snp = Snp.fetch(rs)
    snp.rs_number.should eq(rs)
    ap snp.attributes
    attributes = {
      "rs_number" => 121908378,
      "gene" => "FOXP2",
      "chromosome" => 7,
      "not_reference_assembly" => true,
      "snp_class" => "snp",
      "heterozygosity" => 0.0,
      "het_uncertainty" => 0.0,
      "min_success_rate" => 0.0,
      "max_success_rate" => 0.0,
    }
    snp_attributes = snp.attributes
    snp_attributes.delete("_id")
    snp_attributes.should eq(attributes)
  end
  
  it "should find gene name \"FOXP2\" for rsid# 121908378" do
    rs = 121908378 # foxp2 rs no.
    snp = Snp.fetch(rs)
    snp.gene.should eq("FOXP2")
  end
  
  it "should find organism name \"Agelaius phoeniceus\" for rsid# 119028036" do
    rs = 119028036 # red-winged blackbird rs no.
    snp = Snp.fetch(rs)
    snp.organism.should eq("Agelaius phoeniceus")
  end
  
  it "should find rsid#121908378 is a reference assembly" do
    rs = 121908378
    snp = Snp.fetch(rs)
    snp.not_reference_assembly.should eq(true)
  end
  
  it "should find snp class \"snp\" for rsid#121908378" do
    rs = 121908378
    snp = Snp.fetch(rs)
    snp.snp_class.should eq("snp")
  end
  
  it "should find heterozygosity 0.045 +/- 0.143 for rsid#4884357" do
    rs = 4884357
    snp = Snp.fetch(rs)
    snp.heterozygosity.should eq(0.045)
    snp.het_uncertainty.should eq(0.143)
  end
  
  it "should find success rate 95% for rsid#1494555" do
    rs = 1494555
    snp = Snp.fetch(rs)
    snp.min_success_rate.should eq(95)
    snp.max_success_rate.should eq(99)
  end
  

#  it 'should find it, if it is not found, fetch it'

end
