GenomeProject.blueprint do
  taxonomy { Taxonomy.first || Taxonomy.make_from_fixture_file }
end
