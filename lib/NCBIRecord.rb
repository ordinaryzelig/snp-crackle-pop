# The standard module for an NCBI model.
# Will include Mongoid::Document and add standard methods.
module NCBIRecord


  def self.extended(base)
    base.send :include, Mongoid::Document
    base.instance_eval do
      attr_accessor :xml
    end
  end

  # NCBI database name.
  def database_name
    @database_name ||= name.underscore.downcase
  end

  # Set NCBI database name.
  def database_name=(name)
    @database_name = name
  end

  # What NCBI uses as their ID.
  attr_reader :entrez_id_field

  # Set what NCBI uses as their ID.
  def set_entrez_id_field(field_name)
    @entrez_id_field = field_name
  end

  # Fetch data from NCBI.
  def fetch(entrez_id)
    response = Entrez.efetch(database_name, {id: entrez_id, retmode: 'xml'})
    attributes = parse(response.body)
    object = new(attributes)
    object.xml = response.body
    object
  end

  # Same as fetch and saves to database.
  def fetch!(entrez_id)
    object = fetch(entrez_id)
    object.save!
    object
  end

  # Find from database.
  def find_by_entrez_id(entrez_id)
    where(entrez_id_field => entrez_id).first
  end

  # Find from database, if not found, fetch it from NCBI.
  def find_by_entrez_id_or_fetch(entrez_id)
    find_by_entrez_id(entrez_id) || fetch(entrez_id)
  end

  private

  # Given XML string, parse attributes based on xml procs defined for each field.
  def parse(xml)
    document = Nokogiri::XML(xml)
    fields.inject({}) do |attributes, (field_name, field)|
      xml_proc = field.options[:xml]
      begin
        attributes[field_name] = xml_proc.call(document) if xml_proc
      rescue Exception => ex
        raise ParseError.new(self, field_name, ex)
      end
      attributes
    end
  end

  class ParseError < StandardError
    def initialize(model, field_name, ex)
      super("Error parsing #{model}##{field_name}: #{ex.message}")
    end
  end
end
