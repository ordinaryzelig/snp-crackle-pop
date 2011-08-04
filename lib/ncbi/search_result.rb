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
        fields.each_with_object({}) do |(attribute, parse_proc), attributes|
          attributes[attribute] = parse_proc.call(document)
        end
      end

    end

  end
end
