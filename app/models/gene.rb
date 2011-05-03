class Gene

  include NCBIRecord

  set_entrez_id_field :gene_id

  field :diseases, type: Array,   xml: proc { |doc| doc.css('Entrezgene-Set > Entrezgene > Entrezgene_comments > Gene-commentary > Gene-commentary_comment > Gene-commentary > Gene-commentary_type').select { |node| node.attributes['value'].value == 'phenotype' }.map { |node| node.next.next.content } }
  field :gene_id,  type: Integer, xml: proc { |doc| doc.css('Entrezgene > Entrezgene_track-info > Gene-track > Gene-track_geneid').first.content }

  index :gene_id, unique: true

end
