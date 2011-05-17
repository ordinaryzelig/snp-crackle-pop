# Convenience methods for model to instantiate a new object from the corresponding fixture file.
# Eliminates need to fetch data remotely from NCBI.
# E.G. Snp.from_fixture_file would return a new Snp object from the contents of spec/fixtures/snp_9268480.xml.

MODEL_FIXTURE_FILES = {
  Gene =>          'gene_672.xml',
  GenomeProject => 'genome_project_28911.xml',
  Snp =>           'snp_9268480.xml',
  Taxonomy =>      'taxonomy_9606.xml',
}

MODEL_FIXTURE_FILES.keys.each do |model_class|
  def model_class.from_fixture_file
    fixture_file_name = MODEL_FIXTURE_FILES[self]
    fixture_file = File.open(Padrino.root + '/spec/support/fixtures/' + fixture_file_name)
    xml = fixture_file.read
    send :new_from_xml, xml
  end
end
