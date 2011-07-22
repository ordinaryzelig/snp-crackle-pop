# A data structure that represents a single search result.

module NCBI
  module SearchResult

    def self.included(target)
      target.extend ClassMethods
      target.extend NCBI::XMLParseable
      target.instance_eval do
        # Automatically define ncbi_id field since it's the same for all.
        field(:ncbi_id) { |doc| doc.css('Id').first.content.to_i }
      end
    end

    def initialize(atts = {})
      atts.each do |attribute, value|
        send("#{attribute}=", value)
      end
    end

    module ClassMethods

      def field(attribute, &block)
        attr_accessor attribute
        fields[attribute] = block
      end

      # Given an XML response, parse and return each document summary.
      def parse_esummary(xml)
        document = Nokogiri.XML(xml)
        document.css('DocSum').map do |docsum_node|
          new_from_xml(docsum_node)
        end
      end

      def fields
        @fields ||= {}
      end

      private

      # Parse a Nokogiri::Document and return attributes hash.
      def parse(document)
        document.extend NokogiriDocSummary
        fields.inject({}) do |attributes, (attribute, parse_proc)|
          attributes[attribute] = parse_proc.call(document)
          attributes
        end
      end

    end

  end
end