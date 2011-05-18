module DescriptionMacros

  def it_parses_attribute(attribute, expected_value)
    it attribute do
      pending if expected_value == :pending
      @record.send(attribute).should == expected_value
    end
  end

  def it_raises_error_if_NCBI_cannot_find_it
    model_class = describes
    it 'raises error if NCBI cannot find it' do
      proc { model_class.fetch('asdf') }.should raise_error(NCBIRecord::NotFound)
      proc { model_class.fetch(9876543210) }.should raise_error(NCBIRecord::NotFound)
    end
  end

  # Clicking link to get updates will refetch data.
  # Start object with attribute set to initial value.
  def it_can_be_refetched(attribute, initial_value)
    model_class = description.singularize.classify.constantize
    it 'can be refetched' do
      object = model_class.make_from_fixture_file(attribute => initial_value)
      stub_entrez_request_with_contents_of_fixture_file model_class
      visit url_for(object)
      click_link('Get updates')
      updated_value = model_class.from_fixture_file.send(attribute)
      page.should have_content(updated_value.to_s)
    end
  end

end
