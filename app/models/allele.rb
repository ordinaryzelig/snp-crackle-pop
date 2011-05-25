class Allele

  include NCBI::Document

  verify_xml { |doc| doc.css('FxnSet') }

  field      :base,           type: String, xml: proc { |doc| doc.css('FxnSet').first['allele'] }
  field      :function_class, type: String, xml: proc { |doc| doc.css('FxnSet').first['fxnClass'] }
  embedded_in :snp

end
