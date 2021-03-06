# Convenience methods for model to instantiate a new object from the corresponding fixture file.
# Eliminates need to fetch data remotely from NCBI.
# E.G. Snp.from_fixture_file would return a new Snp object from the contents of spec/fixtures/snp_9268480.xml.

MODEL_FIXTURE_FILES = {
  Gene =>                         'gene_55245_efetch.xml',
  Gene::SearchRequest =>          'gene_search_human_esummary.xml',
  Gene::UniqueIdSearchRequest =>  'gene_search_unique_MRPS18B_esummary.xml',
  Gene::SearchResult =>           'gene_search_human_esummary.xml',
  GenomeProject =>                'genome_project_28911_esummary.xml',
  GenomeProject::SearchRequest => 'genome_project_search_1000_Genomes_Project_Pliot_esummary.xml',
  GenomeProject::SearchResult =>  'genome_project_search_1000_Genomes_Project_Pliot_esummary.xml',
  Snp =>                          'snp_9268480_efetch.xml',
  Snp::SearchResult =>            'snp_search_9268480_672_esummary.xml',
  Taxonomy =>                     'taxonomy_9606_efetch.xml',
}

MODEL_FIXTURE_FILES.keys.each do |model_class|

  def model_class.fixture_file
    fixture_file_name = MODEL_FIXTURE_FILES[self]
    fixture_file = File.open(Padrino.root + '/spec/support/fixtures/' + fixture_file_name)
  end

  def model_class.all_from_file(file)
    xml = file.read
    file.rewind
    split_xml(xml).map do |node|
      send :new_from_xml, node
    end
  end

  def model_class.all_from_fixture_file
    all_from_file(fixture_file)
  end

  def model_class.from_fixture_file
    all_from_fixture_file.first
  end

  def model_class.attributes_from_fixture_file
    xml = fixture_file.read
    send :attributes_from_xml, split_xml(xml).first
  end

  def model_class.make_from_fixture_file(atts = {})
    make(attributes_from_fixture_file.merge(atts))
  end

end
