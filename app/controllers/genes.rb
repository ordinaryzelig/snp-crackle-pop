SnpCracklePop.controllers :genes do

  get :index do
    haml :'shared/download'
  end

  get :search do
    @term = params[:q]
    if @term
      @gene_search_results = Gene.search(@term)
    end
    haml :'genes/search'
  end

  get :show, 'genes/:id' do
    @gene = Gene.find_by_ncbi_id_or_fetch!(params[:id])
    @gene.assign_to_child_snps
    haml :'genes/show'
  end

  refetch_action Gene

  download_action Gene

end
