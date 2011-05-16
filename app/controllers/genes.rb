SnpCracklePop.controllers :genes do

  get :show, 'genes/:id' do
    @gene = Gene.find_by_entrez_id_or_fetch!(params[:id])
    @gene.assign_to_child_snps
  end

end
