# The standard module for an NCBI model.
# Will include Mongoid::Document and add standard methods.
module NCBI
  module Document

    def self.included(base)
      base.instance_eval do
        include Mongoid::Document
        include NCBI::Timestamp
        index :ncbi_id, unique: true
        attr_reader :response
      end
      base.extend ClassMethods
      base.extend HasTaxonomy
    end

    def xml
      response.body
    end

    def ncbi_url
      "#{self.class.ncbi_base_uri}#{ncbi_id}"
    end

    private

    def response=(httparty_response)
      @response = httparty_response
    end

    module ClassMethods

      attr_reader :ncbi_base_uri

      def ncbi_database_name
        @ncbi_database_name ||= name.underscore.downcase
      end

      def set_ncbi_database_name(name)
        @ncbi_database_name = name
      end

      def set_ncbi_base_uri(base_uri)
        @ncbi_base_uri ||= base_uri
      end

      # Fetch data from NCBI.
      # Instantiate new object and return.
      # Record response.
      def fetch(ncbi_id)
        response = perform_entrez_request(ncbi_id)
        object = new_from_xml(response.body)
        object.send(:response=, response)
        object.fetched = true
        object
      rescue XMLCouldNotBeVerified
        # This might happen if ncbi_id was the correct format, but it wasn't found anyway.
        raise NotFound.new(ncbi_id, self)
      rescue BadResponse
        # This could either be a badly formed request, or more likely, ncbi_id was not valid.
        raise NotFound.new(ncbi_id, self)
      end

      # Same as fetch and saves to database.
      def fetch!(*args)
        object = fetch(*args)
        object.save!
        object
      end

      # Find from database.
      def find_by_ncbi_id(ncbi_id)
        where(ncbi_id: ncbi_id).first
      end

      # Find from database, if not found, fetch! it from NCBI (and store it in DB).
      def find_by_ncbi_id_or_fetch!(ncbi_id)
        find_by_ncbi_id(ncbi_id) || fetch!(ncbi_id)
      end

      # Some naming convenience methods.

      def model_name
        @model_name ||= ActiveModel::Name.new(self)
      end

      def humanize
        model_name.human
      end

      def collectionize
        model_name.collection
      end

      # End of naming convenience methods.

      private

      # Given Nokogiri XML document, parse attributes based on xml procs defined for each field and relation.
      # XML instructions are attached as the :xml option for a field or relation.
      # XML instructions can be proc with Nokogiri document as arg or symbol for method to be called.
      # Return attributes hash.
      def parse(document)
        attributes = {}
        attributes.merge! parse_fields(document)
        attributes.merge! parse_relations(document)
        attributes
      end

      # Field options that contain :xml key will have proc to parse doc.
      # Assign attribute field to value of called proc.
      def parse_fields(document)
        fields.inject({}) do |attributes, (field_name, field_object)|
          begin
            xml_proc = (field_object.options || {})[:xml]
            attributes[field_name] = xml_proc.call(document) if xml_proc
            attributes
          rescue Exception => ex
            raise NCBI::Document::ParseError.new(self, field_name, ex)
          end
        end
      end

      # Relations with options that contain :xml key will pass symbol of method to be called.
      # Assign relation_attributes (e.g. alleles_attributes) to result.
      def parse_relations(document)
        relations.inject({}) do |attributes, (relation_name, relation_object)|
          begin
            method_name = (relation_object.options || {})[:xml]
            if method_name
              relation_attributes_name = relation_name + '_attributes'
              attributes[relation_attributes_name] = send(method_name, document)
            end
            attributes
          rescue Exception => ex
            raise NCBI::Document::ParseError.new(self, relation_name, ex)
          end
        end
      end

      # Instantiate a new object from an XML string.
      def new_from_xml(xml)
        new(attributes_from_xml(xml))
      end

      def attributes_from_xml(xml)
        document = Nokogiri.XML(xml)
        raise XMLCouldNotBeVerified.new(xml) unless verify_xml document
        parse(document)
      end

      # Override to customize how data is fetched from Entrez.
      # See GenomeProject for example.
      def perform_entrez_request(ncbi_id)
        response = Entrez.EFetch(ncbi_database_name, {id: ncbi_id, retmode: 'xml'})
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
        super("Error parsing #{model}##{field_name}\n#{ex.class}: #{ex.message}")
      end
    end

    class NotFound < StandardError
      def initialize(ncbi_id, model_class)
        super("NCBI could not find #{model_class.name.humanize} with id: #{ncbi_id}")
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
end
