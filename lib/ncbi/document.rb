# The ORM for an NCBI model.
# Will include Mongoid::Document and add standard methods.

module NCBI
  module Document

    def self.included(base)
      class << base
        attr_reader :ncbi_base_uri
        attr_reader :unique_id_field
        attr_reader :unique_id_search_field
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

      # Cache field name and create DB unique index.
      def set_unique_id_field(field_name)
        @unique_id_field = field_name
        index field_name, unique: true
      end

      # Set the search field that will be used to for Entrez.ESearch to search by a unique identifier.
      def set_unique_id_search_field(field_name)
        @unique_id_search_field = field_name
      end

      # Fetch data from NCBI.
      # Instantiate new object and return.
      # Record response.
      # Can fetch single id or array of ids.
      def fetch(ncbi_id_or_ids)
        ids = [ncbi_id_or_ids].flatten.map(&:to_i)
        response = perform_entrez_request(ids)
        verify_response(response)
        # Split into individual sections, parse, and instantiate objects.
        objects = new_from_splitting_xml(response.body)
        objects.each { |obj| obj.response = response }
        # Verify all found.
        ids_not_found = ids - objects.map(&:ncbi_id)
        raise NotFound.new(ids_not_found) if ids_not_found.any?
        if ncbi_id_or_ids.respond_to?(:each)
          objects
        else
          objects.first
        end
      rescue NCBI::XMLParseable::XMLCouldNotBeVerified
        # This might happen if ncbi_ids had the correct format, but were not found anyway.
        raise NotFound.new(ncbi_id_or_ids)
      rescue BadResponse
        # This could either be a badly formed request, or more likely, ncbi_ids were not valid.
        raise NotFound.new(ncbi_id_or_ids)
      end

      # Same as fetch and saves to database.
      def fetch!(ncbi_id_or_ids)
        object = fetch(ncbi_id_or_ids)
        [object].flatten.each(&:save!)
        object
      end

      def search_by_unique_id_field(ids)
        self::UniqueIdSearchRequest.new(ids).execute
      end

      def find_all_by_unique_id_field_or_fetch_by_unique_id_field!(unique_ids)
        # Use case-insensitive regular expressions to search for strings
        mongoid_field = fields[unique_id_field.to_s]
        formatted_ids = case mongoid_field.type.name
          when 'String'
            unique_ids.map { |unique_id| Regexp.new(unique_id.to_s, true) }
          when 'Integer'
            unique_ids.map { |unique_id| unique_id.to_i }
          else
             raise "#{mongoid_field.type} not implemented"
          end
        found_locally = where(unique_id_field.in => formatted_ids)
        did_not_find_all = found_locally.count < unique_ids.size
        if did_not_find_all
          # Search for all and subtract from ids found locally.
          search_results = search_by_unique_id_field(unique_ids)
          ids_not_found_locally = search_results.map(&:ncbi_id) - found_locally.map(&:ncbi_id)
          fetch!(ids_not_found_locally)
        end
        found_locally
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
        fetch!(ids_not_found_locally) if ids_not_found_locally.any?
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

      # Given Nokogiri XML document_or_node, parse attributes based on xml lambdas defined for each field and relation.
      # XML instructions are attached as the :xml option for a field or relation.
      # XML instructions can be lambda with Nokogiri document_or_node as arg or symbol for method to be called.
      # Return attributes hash.
      def parse(document_or_node)
        attributes = {}
        verify_xml(document_or_node)
        attributes.merge! parse_fields(document_or_node)
        attributes.merge! parse_relations(document_or_node)
        attributes
      end

      # Field options that contain :xml key will have lambda to parse doc.
      # Assign attribute field to value of lambda.
      def parse_fields(document_or_node)
        fields.each_with_object({}) do |(field_name, field_object), attributes|
          begin
            xml_lambda = (field_object.options || {})[:xml]
            attributes[field_name] = xml_lambda.call(document_or_node) if xml_lambda
          rescue Exception => ex
            # Uncomment for debugging.
            # raise NCBI::Document::ParseError.new(self, field_name, ex)
          end
        end
      end

      def parse_relations(document_or_node)
        relations.each_with_object({}) do |(relation_name, relation_object), attributes|
          begin
            xml_lambda = (relation_object.options || {})[:xml]
            if xml_lambda
              case relation_object.macro
              when :embeds_many
                attributes[relation_name] = parse_embeds_many_relation(relation_object, xml_lambda.call(document_or_node))
              else
                raise "parse_#{relation_object.macro} not yet implemented"
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
      def initialize(ncbi_ids)
        super("NCBI could not find #{model_class.name.humanize} with id(s): #{ncbi_ids}")
      end
      def model_class
        self.class.parent
      end
    end

    class BadResponse < StandardError
      def initialize(response)
        super("bad response (code: #{response.code}):\n" + response.body)
      end
    end

  end
end
