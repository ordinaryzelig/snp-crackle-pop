Snp.blueprint do
end

def Snp.make_from_fixture_file(atts = {})
  make(from_fixture_file.attributes.merge(atts))
end
