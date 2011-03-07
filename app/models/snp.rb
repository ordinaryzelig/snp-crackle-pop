class Snp

  include Mongoid::Document
  #include Mongoid::Timestamps # adds created_at and updated_at fields

  field :rs_number, :type => Integer

  # You can define indexes on documents using the index macro:
  # index :field <, :unique => true>

  def self.fetch!(rs_number)
    results = Entrez.efetch('snp', {id: rs_number, HETZ: 345})
    #... parse XML.
    parsed = Nok0giri::XML.parse(results)
    snp = new rs_number: rs_number
    snp.save!
    snp
  end

  def self.find_or_fetch(rs_number)
    find(rs_number) || fetch(rs_number)
  end

end
