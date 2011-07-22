SnpCracklePop.controllers :snps do

  get :index do
    haml :'shared/download'
  end

  # Instead of searching, just redirect to show.
  get :search do
    rs_number = params[:q]
    if rs_number
      redirect url(:snps, :show, id: rs_number)
    else
      haml :'snps/search'
    end
  end

  get :show, 'snps/:id' do
    @snp = Snp.find_by_ncbi_id_or_fetch!(params[:id])
    haml :'snps/show'
  end

  refetch_action Snp

  download_action Snp

end
