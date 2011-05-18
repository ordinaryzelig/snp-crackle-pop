module MochaMacros

  # Stub an NCBIRecord so that connection to NCBI is not needed.
  # When an NCBIRecord calls perform_Entrez_request,
  # return a response object the fixture file contents as the body.
  def stub_entrez_request_with_contents_of_fixture_file(model_class)
    response = mock()
    fixture_file_contents = model_class.fixture_file.read
    response.stubs(:body).returns(fixture_file_contents)
    model_class.stubs(:perform_Entrez_request).returns(response)
  end

end
