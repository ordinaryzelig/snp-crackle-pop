# A data structure that represents a single search result.

module NCBI
  module SearchResult

    def self.included(target)
      target.extend ClassMethods
      target.extend NCBI::XMLParseable
      target.instance_eval do
        # All searches are ESummary results, so the XML should split the same way.
        split_xml_on { |node| node.css('DocSum') }
        # Automatically define ncbi_id field since it's the same for all.
        field(:ncbi_id) { |doc| doc.css('Id').first.content.to_i }
      end
    end

    def initialize(atts = {})
      atts.each do |attribute, value|
        send("#{attribute}=", value)
      end
    end

    def ncbi_url
      "#{self.class.parent.ncbi_base_uri}#{ncbi_id}"
    end

    # Refers to designated unique_id_field, not ncbi_id.
    def unique_identifier
      send self.class.parent.unique_id_field
    end

    module ClassMethods

      def field(attribute, &block)
        attr_accessor attribute
        fields[attribute] = block
      end

      def fields
        @fields ||= {}
      end

      private

      # Parse a Nokogiri::Document and return attributes hash.
      def parse(node_or_document)
        node_or_document.extend NokogiriDocSummary
        fields.each_with_object({}) do |(attribute, parse_proc), attributes|
          attributes[attribute] = parse_proc.call(node_or_document)
        end
      end

    end

  end
end
