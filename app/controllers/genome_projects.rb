SnpCracklePop.controllers :genome_projects do

  get :search do
    @term = params[:q]
    if @term
      @genome_project_search_results = GenomeProject.search(@term)
    end
    haml :'genome_projects/search'
  end

  get :show, 'genome_projects/:id' do
    @genome_project = GenomeProject.find_by_ncbi_id_or_fetch!(params[:id])
    haml :'genome_projects/show'
  end

  refetch_action GenomeProject

end
