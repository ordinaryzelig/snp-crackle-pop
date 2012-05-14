SnpCracklePop.controllers :snps do

  get :index do
    haml :'snps/download'
  end

  # Perform unique id search or location search.
  get :search do
    @term = params[:q]
    @location = Location.new(params[:location]) if params[:location]
    if @term
      snp = Snp.search(@term)
      redirect url(:snps, :show, id: snp.rs_number)
    elsif @location
      @snp_search_results = Snp.locate(@location)
    end
    haml :'snps/search'
  end

  get :locate, 'snps/locate' do
    haml :'snps/locate'
  end

  post :locate do
    locations = Location.new_from_input(params[:locations])
    objects = Snp.locate_fresh(locations, params[:refetch_if_older_than])
    csv objects.mongoid_to_csv, 'located.csv'
  end

  get :show, 'snps/:id' do
    @snp = Snp.find_by_ncbi_id_or_fetch!(params[:id])
    @snp = Snp.refetch_if_stale!([@snp], 0).first
    haml :'snps/show'
  end

  refetch_action Snp

  download_action Snp

end
