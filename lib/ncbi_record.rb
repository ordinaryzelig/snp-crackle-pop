# The standard module for an NCBI model.
# Will include Mongoid::Document and add standard methods.
module NCBIRecord

  def self.included(base)
    base.instance_eval do
      include Mongoid::Document
      include NCBITimestamp
      index :ncbi_id, unique: true
      attr_reader :response
    end
    base.extend ClassMethods
    base.extend HasTaxonomy
  end

  def xml
    response.body
  end

  # Update with fresh data from NCBI.
  def refetch
    response = self.class.send(:perform_Entrez_request, ncbi_id)
    self.attributes = self.class.send(:attributes_from_xml, response.body)
    set_updated_from_NCBI_at
  end

  def refetch!
    refetch
    save!
  end

  private

  def response=(httparty_response)
    @response = httparty_response
  end

  module ClassMethods

    def ncbi_database_name
      @ncbi_database_name ||= name.underscore.downcase
    end

    def set_ncbi_database_name(name)
      @ncbi_database_name = name
    end

    # Fetch data from NCBI.
    # Instantiate new object and return.
    # Record response.
    def fetch(entrez_id)
      response = perform_Entrez_request(entrez_id)
      object = new_from_xml(response.body)
      object.send(:response=, response)
      object.fetched = true
      object
    rescue XMLCouldNotBeVerified
      # This might happen if entrez_id was the correct format, but it wasn't found anyway.
      raise NotFound.new(entrez_id, self)
    rescue BadResponse
      # This could either be a badly formed request, or more likely, entrez_id was not valid.
      raise NotFound.new(entrez_id, self)
    end

    # Same as fetch and saves to database.
    def fetch!(*args)
      object = fetch(*args)
      object.save!
      object
    end

    # Find from database.
    def find_by_entrez_id(entrez_id)
      where(ncbi_id: entrez_id).first
    end

    # Find from database, if not found, fetch! it from NCBI (and store it in DB).
    def find_by_entrez_id_or_fetch!(entrez_id)
      find_by_entrez_id(entrez_id) || fetch!(entrez_id)
    end

    private

    # Given Nokogiri XML document, parse attributes based on xml procs defined for each field.
    # Return attributes hash.
    def parse(document)
      attributes = {}
      fields.each do |field_name, field|
        xml_proc = field.options[:xml]
        attributes[field_name] = document.extract(field_name, xml_proc) if xml_proc
      end
      attributes
    end

    # Instantiate a new object from an XML string.
    def new_from_xml(xml)
      new(attributes_from_xml(xml))
    end

    def attributes_from_xml(xml)
      document = Nokogiri.XML(xml)
      raise XMLCouldNotBeVerified.new(xml) unless verify_xml document
      attributes = parse(document)
    end

    # Override to customize how data is fetched from Entrez.
    # See GenomeProject for example.
    def perform_Entrez_request(entrez_id)
      response = Entrez.EFetch(ncbi_database_name, {id: entrez_id, retmode: 'xml'})
      raise BadResponse.new(response) unless response.ok?
      response
    end

    # Verify that the XML about to parsed is going to give good data.
    # The verification process is a simple search for a key "ingredient" that
    # if present, probably means that this is a good XML document to parse.
    # This method can be called in 2 ways:
    #   1) In the model where the instructions to search for the key ingredient are located:
    #     class Snp
    #       verify_xml { |doc| doc['KeyIngredient'] }
    #     end
    #   2) In new_from_xml where the document gets passed here for verification.
    def verify_xml(document = nil, &block)
      if block_given?
        # Store for later use.
        @xml_verification_proc = block
      else
        @xml_verification_proc.call(document).present?
      end
    end

  end

  class ParseError < StandardError
    def initialize(model, field_name, ex)
      super("Error parsing #{model}##{field_name}:\n#{ex.message}")
    end
  end

  class NotFound < StandardError
    def initialize(entrez_id, model_class)
      super("Entrez could not find #{model_class.name.humanize} with id: #{entrez_id}")
    end
  end

  class XMLCouldNotBeVerified < StandardError
    def initialize(xml)
      super(xml)
    end
  end

  class BadResponse < StandardError
    def initialize(response)
      super("bad response (code: #{response.code}):\n" + response.body)
    end
  end

end
