module ExampleMacros

  def drop_tables
    Mongoid.master.collections.select do |collection|
      collection.name !~ /system/
    end.each(&:drop)
  end

  def fixture_file(file_name)
    File.open(Padrino.root + '/spec/fixtures/' + file_name)
  end

  def snp_from_fixture_file
    xml = fixture_file("snp_9268480.xml").read
    Snp.send(:new_from_xml, xml)
  end

  def taxonomy_from_fixture_file
    xml = fixture_file('taxonomy_9606.xml').read
    Taxonomy.send(:new_from_xml, xml)
  end

  def gene_from_fixture_file
    xml = fixture_file('gene_672.xml').read
    Gene.send(:new_from_xml, xml)
  end

end
