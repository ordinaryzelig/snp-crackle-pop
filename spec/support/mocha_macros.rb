module MochaMacros

  # Stub an Entrez request with a stubbed response so we can mock Entrez without internet.
  # Stubbed response will return content as body.
  # Stubbed response.ok? will also return true.
  def stub_entrez_request_with_stubbed_response(entrez_request_type, content)
    response = stub({
      :body => content,
      :ok? =>  true,
      :[] =>   nil, # so verify_response will not find 'ERROR'.
      :code => 200,
    })
    Entrez.stubs(entrez_request_type).returns(response)
  end

end
