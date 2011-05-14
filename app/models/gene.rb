class Gene

  include NCBIRecord

  set_entrez_id_field :gene_id
  index :gene_id, unique: true

  field :diseases,      type: Array,   xml: proc { |doc| doc.css('Entrezgene-Set > Entrezgene > Entrezgene_comments > Gene-commentary > Gene-commentary_comment > Gene-commentary > Gene-commentary_type').select { |node| node.attributes['value'].value == 'phenotype' }.map { |node| node.next.next.content } }
  field :gene_id,       type: Integer, xml: proc { |doc| doc.css('Gene-track_geneid').first.content }
  field :location,      type: String,  xml: proc { |doc| doc.css('Gene-ref_maploc').first.content }
  field :mim,           type: Integer, xml: proc { |doc| doc.css('Entrezgene_unique-keys Dbtag_db').detect { |node| node.content == 'MIM' }.next.next.css('Object-id_id').first.content }
  field :name,          type: String,  xml: proc { |doc| doc.css('Gene-ref_desc').first.content }
  field :protein_name,  type: String,  xml: proc { |doc| doc.css('Prot-ref_name_E').first.content }
  field :symbol,        type: String,  xml: proc { |doc| doc.css('Gene-ref_locus').first.content }
  field :symbols_other, type: Array,   xml: proc { |doc| doc.css('Gene-ref_syn Gene-ref_syn_E').map(&:content) }
  field :tax_id,        type: Integer, xml: proc { |doc| doc.css('Org-ref_db Dbtag Dbtag_tag Object-id Object-id_id').first.content }

  has_taxonomy

end
