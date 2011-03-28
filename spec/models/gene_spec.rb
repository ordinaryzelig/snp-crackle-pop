require 'spec_helper'

describe Gene do

  it 'fetches gene_id' do
    gene_id = 672
    gene = Gene.find_by_entrez_id_or_fetch!(gene_id)
    gene.gene_id.should eq(gene_id)
  end

  it 'fetches diseases' do
    gene_id = 672
    gene = Gene.find_by_entrez_id_or_fetch!(gene_id)
    gene.diseases.should eq(["Breast cancer", "Breast-ovarian cancer, familial, 1", "Pancreatic cancer, susceptibility to, 4"])
  end

end
