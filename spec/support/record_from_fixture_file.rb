# Convenience methods for model to instantiate a new object from the corresponding fixture file.
# Eliminates need to fetch data remotely from NCBI.
# E.G. Snp.from_fixture_file would return a new Snp object from the contents of spec/fixtures/snp_9268480.xml.

MODEL_FIXTURE_FILES = {
  Gene =>                         'gene_672.xml',
  Gene::SearchRequest =>          'gene_esummary.xml',
  GenomeProject =>                'genome_project_28911.xml',
  GenomeProject::SearchRequest => 'genome_project_esummary.xml',
  Snp =>                          'snp_9268480.xml',
  Taxonomy =>                     'taxonomy_9606.xml',
}

MODEL_FIXTURE_FILES.keys.each do |model_class|

  def model_class.fixture_file
    fixture_file_name = MODEL_FIXTURE_FILES[self]
    fixture_file = File.open(Padrino.root + '/spec/support/fixtures/' + fixture_file_name)
  end

  def model_class.from_fixture_file
    xml = fixture_file.read
    send :new_from_xml, xml
  end

  def model_class.attributes_from_fixture_file
    send :attributes_from_xml, fixture_file.read
  end

  def model_class.make_from_fixture_file(atts = {})
    make(attributes_from_fixture_file.merge(atts))
  end

end
