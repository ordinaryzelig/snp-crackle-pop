class Gene

  include NCBIRecord

  verify_xml { |doc| doc.css('Entrezgene') }

  field :diseases,         type: Array,   xml: proc { |doc| doc.css('Entrezgene-Set > Entrezgene > Entrezgene_comments > Gene-commentary > Gene-commentary_comment > Gene-commentary > Gene-commentary_type').select { |node| node.attributes['value'].value == 'phenotype' }.map { |node| node.next.next.content } }
  field :location,         type: String,  xml: proc { |doc| doc.css('Gene-ref_maploc').first.content }
  field :mim,              type: Integer, xml: proc { |doc| doc.css('Entrezgene_unique-keys Dbtag_db').detect { |node| node.content == 'MIM' }.next.next.css('Object-id_id').first.content }
  field :name,             type: String,  xml: proc { |doc| doc.css('Gene-ref_desc').first.content }
  field :ncbi_id,          type: Integer, xml: proc { |doc| doc.css('Gene-track_geneid').first.content }
  field :ncbi_taxonomy_id, type: Integer, xml: proc { |doc| doc.css('Org-ref_db Dbtag Dbtag_tag Object-id Object-id_id').first.content }
  field :protein_name,     type: String,  xml: proc { |doc| doc.css('Prot-ref_name_E').first.content }
  field :symbol,           type: String,  xml: proc { |doc| doc.css('Gene-ref_locus').first.content }
  field :symbols_other,    type: Array,   xml: proc { |doc| doc.css('Gene-ref_syn Gene-ref_syn_E').map(&:content) }

  has_many :snps

  has_taxonomy

  # For any Snps that have the same gene_id,
  # but don't yet have a gene object in the db,
  # assign this one to them.
  def assign_to_child_snps
    Snp.without_gene_object.for_ncbi_gene_id(self.ncbi_id).update_all(gene_id: self.id)
  end

  def symbol_and_name
    "#{symbol}: #{name}"
  end

  class << self

    def search(term)
      return [] if term.blank?
      reg_exp = Regexp.new(term, true)
      conditions = [:location, :name, :protein_name, :symbol, :symbols_other].map do |field_to_search|
        {field_to_search => reg_exp}
      end
      any_of(conditions)
    end

  end

end
