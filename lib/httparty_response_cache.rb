# Provide simple methods to cache response.

module HTTPartyResponse

  attr_reader :response

  def xml
    response.body
  end

  private

  def response=(httparty_response)
    @response = httparty_response
  end

end
