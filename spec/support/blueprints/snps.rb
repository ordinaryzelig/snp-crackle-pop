Snp.blueprint do
  # Workaround just to get something assigned and have rs_number be something.
  ncbi_id { 1 }
  rs_number { ncbi_id }
  taxonomy { Taxonomy.first || Taxonomy.make_from_fixture_file }
end
