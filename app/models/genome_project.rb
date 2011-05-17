class GenomeProject

  include NCBIRecord

  set_ncbi_database_name 'genomeprj'
  verify_xml { |doc| doc.css('Id') }

  field :name,               type: String,  xml: proc { |doc| doc.xpath('.//Item[@Name="Defline"]').first.content }
  field :ncbi_taxonomy_id,   type: Integer, xml: proc { |doc| doc.xpath('.//Item[@Name="TaxId"]').first.content }
  field :ncbi_id,            type: Integer, xml: proc { |doc| doc.xpath('.//Id').first.content }
  field :sequencing_centers, type: Array,   xml: proc { |doc| doc.xpath('.//Item[@Name="Center"]').map(&:content) }
  field :sequencing_status,  type: String,  xml: proc { |doc| doc.xpath('.//Item[@Name="Sequencing_Status"]').first.content }
  belongs_to :taxonomy

  class << self

    # Search scientific_name, genbank_common_name, and common_name.
    def search(name)
      reg_exp = Regexp.new(name, true)
      conditions = [:scientific_name, :genbank_common_name, :common_name].map do |field_to_search|
        {field_to_search => reg_exp}
      end
      any_of(conditions)
    end

    private

    # Customize fetching data using ESummary instead of EFetch.
    def perform_Entrez_request(entrez_id)
      Entrez.ESummary(ncbi_database_name, {id: entrez_id, retmode: 'xml'})
    end

  end

end
