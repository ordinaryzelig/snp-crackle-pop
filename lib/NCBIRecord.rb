# The standard module for an NCBI model.
# Will include Mongoid::Document and add standard methods.
module NCBIRecord

  def self.included(base)
    base.send :include, Mongoid::Document
    base.extend ClassMethods
    base.instance_eval do
      attr_reader   :response
    end
  end

  def xml
    response.body
  end

  private

  def response=(httparty_response)
    @response = httparty_response
  end

  module ClassMethods

    # NCBI database name.
    def database_name
      @database_name ||= name.underscore.downcase
    end

    # Set NCBI database name.
    def set_database_name(name)
      @database_name = name
    end

    # What NCBI uses as their ID.
    attr_reader :entrez_id_field

    # Set what NCBI uses as their ID.
    # Set that field as a MongoDB uniq index.
    def set_entrez_id_field(field_name)
      @entrez_id_field = field_name
      index @entrez_id_field, unique: true
    end

    # Fetch data from NCBI.
    # Instantiate new object and return.
    # Record response.
    def fetch(entrez_id)
      response = perform_Entrez_request(entrez_id)
      object = new_from_xml(response.body)
      object.send(:response=, response)
      object
    end

    # Same as fetch and saves to database.
    def fetch!(*args)
      object = fetch(*args)
      object.save!
      object
    end

    # Find from database.
    def find_by_entrez_id(entrez_id)
      where(entrez_id_field => entrez_id).first
    end

    # Find from database, if not found, fetch! it from NCBI (and store it in DB).
    def find_by_entrez_id_or_fetch!(entrez_id)
      find_by_entrez_id(entrez_id) || fetch!(entrez_id)
    end

    private

    # Given XML string, parse attributes based on xml procs defined for each field.
    # Return attributes hash.
    def parse(xml)
      document = Nokogiri::XML(xml)
      attributes = {}
      fields.each do |field_name, field|
        xml_proc = field.options[:xml]
        attributes[field_name] = document.extract(field_name, xml_proc) if xml_proc
      end
      attributes
    end

    def new_from_xml(xml)
      attributes = parse(xml)
      new(attributes)
    end

    # Override to customize how data is fetched from Entrez.
    # See GenomeProject for example.
    def perform_Entrez_request(entrez_id)
      Entrez.EFetch(database_name, {id: entrez_id, retmode: 'xml'})
    end

  end

  class ParseError < StandardError
    def initialize(model, field_name, ex)
      super("Error parsing #{model}##{field_name}:\n#{ex.message}")
    end
  end

end
