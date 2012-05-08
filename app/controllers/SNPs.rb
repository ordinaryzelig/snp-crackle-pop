SnpCracklePop.controllers :snps do

  get :index do
    haml :'snps/download'
  end

  # Perform unique id search or location search.
  get :search do
    @term = params[:q]
    @location = params[:location]
    if @term
      snp = Snp.search(@term)
      redirect url(:snps, :show, id: snp.rs_number)
    elsif @location
      @snp_search_results = Snp.locate(@location)
    end
    haml :'snps/search'
  end

  get :show, 'snps/:id' do
    @snp = Snp.find_by_ncbi_id_or_fetch!(params[:id])
    haml :'snps/show'
  end

  refetch_action Snp

  download_action Snp

end
