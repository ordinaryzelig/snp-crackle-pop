# Currently, nobody cares WHAT association, just that there IS an association.
# Use NCBI's PhenGenI.
#
# The URL was extracted from the form to download a tab-delimited file with the association data.
# From a SNP's NCBI page, click on the PhenGenI link. It will take you to PhenGenI. In the Assciation section,
# there is a download button. This is where this URL comes from. However, there is a bit of JavaScript required to arrive at this URL.
class SnpAssociation

  URL_TEMPLATE = 'http://www.ncbi.nlm.nih.gov/gap/PheGenI?rs=%s&tab=2&type=text&data=SNP&log_op=downloadAssocText_L&p%24l=AssocText_L&p%24st=gap'

  attr_accessor :rs_number

  class << self

    # Make request, parse, and return SnpAssociation object.
    # If the association does not exist, return nil.
    def fetch(rs_number)
      rs_number = parse(request(rs_number).body)
      if rs_number
        snp_association = SnpAssociation.new
        snp_association.rs_number = rs_number
        snp_association
      end
    end

    private

    def request(rs_number)
      url = URL_TEMPLATE.sub('%s', rs_number.to_s)
      uri = URI.parse(url)
      Net::HTTP.get_response(uri)
    end

    # Parse and return the SNP rs value.
    # Currently, the response we're looking for is anything that looks like results.
    # If the SNP does not have associations, PhenGenI returns a "possible timeout" message.
    def parse(text)
      header_row, body_row = text.split(/$/)
      headers = header_row.split("\t")
      rs_index = headers.index('SNP rs')
      return false unless rs_index
      values = body_row.split("\t")
      values[rs_index]
    end

  end

end
