class Snp

  include Mongoid::Document
  #include Mongoid::Timestamps # adds created_at and updated_at fields

  field :rs_number, :type => Integer
  field :chromosome, :type => Integer
  field :gene, :type => String
  field :accession, :type => Integer
  field :organism, :type => String
  field :function_class, :type => Integer
  field :not_reference_assembly, :type => Boolean
  field :heterozygosity, :type => Float
  field :het_uncertainty, :type => Float
  field :min_success_rate, :type => Float
  field :max_success_rate, :type => Float
  field :allele, :type => String
  field :snp_class, :type => String
  field :base_position, :type => Integer

  # You can define indexes on documents using the index macro:
  # index :field <, :unique => true>

  def self.fetch(rs_number)
    response = Entrez.efetch('snp', {id: rs_number, retmode: 'xml'})
    #... parse XML.
    document = Nokogiri::XML(response.body)
    testfile = File.new(rs_number.to_s() + ".xml", "w")
    testfile.puts(document)
    testfile.close
    rsId = document.root.css('Rs').first['rsId']
    chromosome = document.root.css('Rs Assembly Component').first['chromosome']
    gene = document.root.css('Rs Assembly Component MapLoc FxnSet').first['symbol']
    #accession      Many accessions, grab all?
    #organism = document.root.css('SourceDatabase').first['organism']
    #function_class
    not_reference_assembly = document.root.css('Rs Assembly').first['reference']
    heterozygosity = document.root.css('Rs Het').first['value'].to_f().round(3)
    het_uncertainty = document.root.css('Rs Het').first['stdError'].to_f().round(3)
    min_success_rate = document.root.css('Rs').first['validProbMin'].to_f()
    max_success_rate = document.root.css('Rs').first['validProbMax'].to_f()
    #allele
    snp_class = document.root.css('Rs').first['snpClass']
    #base_position
    snp = new rs_number: rsId, chromosome: chromosome, gene: gene,
          not_reference_assembly: not_reference_assembly, snp_class: snp_class,
          heterozygosity: heterozygosity, het_uncertainty: het_uncertainty,
          min_success_rate: min_success_rate, max_success_rate: max_success_rate
    #snp.save!
    snp
  end

  def self.find_or_fetch(rs_number)
    where(rs_number: rs_number).first || fetch!(rs_number)
  end

  class << self

    def search(rs_number)
      find_or_fetch rs_number
    end

  end

end
