SnpCracklePop.controllers :snps do

  get :index do
    haml :'snps/download'
  end

  # Perform unique id search.
  get :search do
    if params[:q]
      rs_number = params[:q].match(/(?<number>\d+)/)[:number]
      snp = Snp.find_all_by_unique_id_field_or_fetch_by_unique_id_field!([rs_number]).first
      redirect url(:snps, :show, id: snp.rs_number)
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
