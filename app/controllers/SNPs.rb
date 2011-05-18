SnpCracklePop.controllers :snps do

  get :search do
    rs_number = params[:q]
    if rs_number
      redirect url(:snps, :show, id: rs_number)
    else
      haml :'snps/search'
    end
  end

  get :show, 'snps/:id' do
    @snp = Snp.find_by_entrez_id_or_fetch!(params[:id])
    haml :'snps/show'
  end

  refetch_action Snp

end
