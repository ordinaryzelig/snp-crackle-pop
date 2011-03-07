SnpCracklePop.controllers :snps do

  get :index do
    #@snp = Snp.find_or_fetch(params[:rs_number]) if params[:rs_number].present?
    @snp = Snp.first
    haml :'snps/index'
  end

end
