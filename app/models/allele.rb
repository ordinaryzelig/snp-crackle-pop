# Parsed and processed with Snp.
class Allele

  include NCBI::Document

  # Should only be parsed with function set node.
  verify_xml { |node| node.to_s =~ /^\<FxnSet/ }

  field       :base,           type: String, xml: proc { |node| node['allele'] }
  field       :function_class, type: String, xml: proc { |node| node['fxnClass'] }
  embedded_in :snp

end
