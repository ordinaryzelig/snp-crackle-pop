SnpCracklePop.controllers :genes do

  get :index do
    haml :'genes/download'
  end

  get :search do
    @term = params[:q]
    @location = params[:location]
    if @term
      @gene_search_results = Gene.search(@term)
    elsif @location
      @gene_search_results = Gene.locate(@location)
    end
    haml :'genes/search'
  end

  get :show, 'genes/:id' do
    @gene = Gene.find_by_ncbi_id_or_fetch!(params[:id])
    haml :'genes/show'
  end

  refetch_action Gene

  download_action Gene

end
