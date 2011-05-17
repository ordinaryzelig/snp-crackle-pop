Taxonomy.blueprint do
end

def Taxonomy.make_from_fixture_file(atts = {})
  make(from_fixture_file.attributes.merge(atts))
end
