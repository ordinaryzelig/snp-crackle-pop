# Parsed and processed with Snp.
class Allele

  include NCBI::Document

  # Should only be parsed with function set node.
  verify_xml { |node| node.to_s =~ /^\<FxnSet/ }

  field       :base,           type: String, xml: lambda { |node| node['allele'] }
  field       :function_class, type: String, xml: lambda { |node| node['fxnClass'] }
  embedded_in :snp

  # Compare everything except _id.
  def ==(allele)
    self.class.fields.keys.all? do |field|
      send(field) == allele.send(field)
    end
  end

end
