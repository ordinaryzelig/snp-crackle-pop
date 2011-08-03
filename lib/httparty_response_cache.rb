# Provide simple methods to cache response.

module HTTPartyResponse

  attr_accessor :response

  # YAGNI: Allow to be assigned instead of always referring to @response.
  def xml
    # HTTParty::Response overwrites #try.
    @response.body if @response
  end

end
