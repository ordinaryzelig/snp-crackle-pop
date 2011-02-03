class Snp

  include Mongoid::Document
  #include Mongoid::Timestamps # adds created_at and updated_at fields

  field :rs_number, :type => Integer

  # You can define indexes on documents using the index macro:
  # index :field <, :unique => true>

  def self.fetch_hash(rs_number)
    Eutils.new('ruby', 'jared@redningja.com').efetch('snp', nil, nil, {id: rs_number})
  end

  def self.fetch(rs_number)
    hash = fetch_hash rs_number
    new(rs_number: hash['ExchangeSet']['Rs']['rsId'])
  end

end
