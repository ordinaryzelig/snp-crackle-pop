class Snp

  include Mongoid::Document

  field :rs_number,              type: Integer, xml: proc { |doc| doc.css('Rs').first['rsId'] }
  field :chromosome,             type: Integer, xml: proc { |doc| doc.css('Rs Assembly Component').first['chromosome'] }
  field :gene,                   type: String,  xml: proc { |doc| doc.css('Rs Assembly Component MapLoc FxnSet').first['symbol'] }
  field :accession,              type: Integer  # Many accessions, grab all?
  field :organism,               type: String#,  xml: proc { |doc| doc.css('SourceDatabase').first['organism'] }
  field :function_class,         type: Integer
  field :not_reference_assembly, type: Boolean, xml: proc { |doc| doc.css('Rs Assembly').first['reference'] }
  field :heterozygosity,         type: Float,   xml: proc { |doc| doc.css('Rs Het').first['value'].to_f().round(3) }
  field :het_uncertainty,        type: Float,   xml: proc { |doc| doc.css('Rs Het').first['stdError'].to_f().round(3) }
  field :min_success_rate,       type: Float,   xml: proc { |doc| doc.css('Rs').first['validProbMin'].to_f() }
  field :max_success_rate,       type: Float,   xml: proc { |doc| doc.css('Rs').first['validProbMax'].to_f() }
  field :allele,                 type: String
  field :snp_class,              type: String,  xml: proc { |doc| doc.css('Rs').first['snpClass'] }
  field :base_position,          type: Integer

  # You can define indexes on documents using the index macro:
  # index :field <, :unique => true>

  class << self

    def fetch(rs_number)
      response = Entrez.efetch('snp', {id: rs_number, retmode: 'xml'})
      attributes = parse(response.body)
      snp = new(attributes)
      #snp.save!
      snp
    end

    def find_or_fetch(rs_number)
      where(rs_number: rs_number).first || fetch!(rs_number)
    end

    private

    # Given XML string, parse attributes based on xml procs defined for each field.
    def parse(xml)
      document = Nokogiri::XML(xml)
      fields.inject({}) do |attributes, (field_name, field)|
        xml_proc = field.options[:xml]
        attributes[field_name] = xml_proc.call(document) if xml_proc
        attributes
      end
    end

  end

end
