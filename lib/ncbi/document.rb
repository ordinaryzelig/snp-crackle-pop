# The ORM for an NCBI model.
# Will include Mongoid::Document and add standard methods.

module NCBI
  module Document

    def self.included(base)
      class << base
        attr_reader :ncbi_base_uri
      end
      base.instance_eval do
        include Mongoid::Document
        include NCBI::Timestamp
        include HTTPartyResponse
        extend NCBI::XMLParseable
        index :ncbi_id, unique: true
      end
      base.extend ClassMethods
      base.extend HasTaxonomy
    end

    def ncbi_url
      "#{self.class.ncbi_base_uri}#{ncbi_id}"
    end

    module ClassMethods

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
      # Can fetch single id or array of ids.
      def fetch(ncbi_id_or_ids)
        ids = [ncbi_id_or_ids].flatten
        response = perform_entrez_request(ids)
        verify_response(response)
        # Split into individual sections, parse, and instantiate objects.
        objects = split_xml(response.body).map do |node|
          object = new_from_xml(node)
          object.send(:response=, response)
          object.fetched = true
          object
        end
        # Verify all found.
        ids_not_found = ids - objects.map(&:ncbi_id)
        raise NotFound.new(ids_not_found, self) if ids_not_found.any?
        if ncbi_id_or_ids.respond_to?(:each)
          objects
        else
          objects.first
        end
        # TODO: raise exception if any not found.
      rescue NCBI::XMLParseable::XMLCouldNotBeVerified
        # This might happen if ncbi_ids had the correct format, but were not found anyway.
        raise NotFound.new(ncbi_id_or_ids, self)
      rescue BadResponse
        # This could either be a badly formed request, or more likely, ncbi_ids were not valid.
        raise NotFound.new(ncbi_id_or_ids, self)
      end

      # Same as fetch and saves to database.
      def fetch!(ncbi_id_or_ids)
        object = fetch(ncbi_id_or_ids)
        [object].flatten.each(&:save!)
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

      # Find objects that already exist in local DB.
      # If any not found locally, fetch from NCBI.
      def find_all_by_ncbi_id_or_fetch!(ncbi_ids)
        found_locally = with_ncbi_ids(ncbi_ids)
        ids_not_found_locally = ncbi_ids - found_locally.map(&:ncbi_id)
        if ids_not_found_locally.any?
          fetched = fetch!(ids_not_found_locally)
        else
          fetched = []
        end
        # found_locally is a Mongoid::Criteria object.
        # Since we are fetch!-ing, the new objects are being stored in the DB.
        # Criteria will query the DB each time it is accessed.
        # So now all should be "found locally".
        found_locally
      end

      def with_ncbi_ids(ids)
        where :ncbi_id.in => ids
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

      # Given Nokogiri XML document_or_node, parse attributes based on xml procs defined for each field and relation.
      # XML instructions are attached as the :xml option for a field or relation.
      # XML instructions can be proc with Nokogiri document_or_node as arg or symbol for method to be called.
      # Return attributes hash.
      def parse(document_or_node)
        attributes = {}
        verify_xml(document_or_node)
        attributes.merge! parse_fields(document_or_node)
        attributes.merge! parse_relations(document_or_node)
        attributes
      end

      # Field options that contain :xml key will have proc to parse doc.
      # Assign attribute field to value of called proc.
      def parse_fields(document_or_node)
        fields.inject({}) do |attributes, (field_name, field_object)|
          begin
            xml_proc = (field_object.options || {})[:xml]
            attributes[field_name] = xml_proc.call(document_or_node) if xml_proc
            attributes
          rescue Exception => ex
            # Uncomment for debugging.
            # raise NCBI::Document::ParseError.new(self, field_name, ex)
            attributes
          end
        end
      end

      def parse_relations(document_or_node)
        relations.each_with_object({}) do |(relation_name, relation_object), attributes|
          begin
            xml_proc = (relation_object.options || {})[:xml]
            if xml_proc
              case relation_object.macro
              when :embeds_many
                attributes[relation_name] = parse_embeds_many_relation(relation_object, xml_proc.call(document_or_node))
              end
            end
          rescue Exception => ex
            raise NCBI::Document::ParseError.new(self, relation_name, ex)
          end
        end
      end

      # Given nodes, extract attributes and return array of attributes.
      def parse_embeds_many_relation(relation_object, nodes)
        nodes.each_with_object([]) do |node, attributes|
          relation_class = Object.const_get(relation_object.class_name)
          attributes << relation_class.attributes_from_xml(node)
        end
      end

      # Override to customize how data is fetched from Entrez.
      # See GenomeProject for example.
      def perform_entrez_request(ncbi_ids)
        ids_string = [ncbi_ids].flatten.join(',')
        Entrez.EFetch(ncbi_database_name, id: ids_string)
      end

      # HTTParty response must have 200 status and
      # if it is the result of an ESummary, there must not be an error.
      def verify_response(response)
        if response['eSummaryResult']
          esummary_error = response['eSummaryResult'].has_key?('ERROR')
        end
        unless response.ok? && !esummary_error
          raise BadResponse.new(response)
        end
      end

    end

    class ParseError < StandardError
      def initialize(model, field_name, ex)
        super("Error parsing #{model}##{field_name}\n#{ex.class}: #{ex.message}")
        set_backtrace(ex.backtrace)
      end
    end

    class NotFound < StandardError
      def initialize(ncbi_ids, model_class)
        super("NCBI could not find #{model_class.name.humanize} with id(s): #{ncbi_ids}")
      end
    end

    class BadResponse < StandardError
      def initialize(response)
        super("bad response (code: #{response.code}):\n" + response.body)
      end
    end

  end
end
