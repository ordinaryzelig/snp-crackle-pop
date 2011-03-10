SnpCracklePop.controllers :snps do

  get :index do
    if params[:rs_number]
      @snp = Snp.fetch(params[:rs_number])
    end
    haml :'snps/index'
  end

end
