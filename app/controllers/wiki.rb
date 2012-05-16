SnpCracklePop.controllers :wiki do

  layout :application

  get :index do
    wiki 'home'
  end

  get :show, 'wiki/:id' do
    wiki params[:id]
  end

end
