# Class method helpers to generate attributes from XML.
# Class is responsible for implementing parse() method.

module NCBI
  module XMLParseable

    def new_from_xml(xml)
      new(attributes_from_xml(xml))
    end

    # Parse XML and return attributes hash.
    # If XML is string, create Nokogiri::Document.
    def attributes_from_xml(xml)
      document = case xml
        when String
          Nokogiri.XML(xml)
        else
          xml
        end
      parse(document)
    end

    # Define instructions on how to split multiple EFetch results.
    def split_xml_on(&block)
      @split_proc = block
    end

    # Using split_proc, split the Nokogiri::Document which should return an array of Nokogiri nodes.
    def split_xml(string)
      doc = Nokogiri.XML(string)
      raise "no split_on defined for #{self}" unless @split_proc
      @split_proc.call(doc)
    end

    private

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
        raise XMLCouldNotBeVerified.new(document.to_s) unless @xml_verification_proc.call(document).present?
      end
    end

    class XMLCouldNotBeVerified < StandardError
      def initialize(xml)
        super(xml)
      end
    end

  end
end
