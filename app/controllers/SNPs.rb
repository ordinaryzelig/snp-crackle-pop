SnpCracklePop.controllers :snps do

  get :index do
    if params[:rs_number]
      @snp = Snp.find_by_entrez_id_or_fetch!(params[:rs_number])
    end
    haml :'snps/index'
  end

end
