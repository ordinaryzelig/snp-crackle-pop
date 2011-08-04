module DescriptionMacros

  def it_parses_attribute(attribute, expected_value)
    it attribute do
      pending if expected_value == :pending
      @object.send(attribute).should == expected_value
    end
  end

  def it_raises_error_if_ncbi_cannot_find_it
    model_class = describes
    it 'raises error if NCBI cannot find it' do
      lambda { model_class.fetch('asdf') }.should raise_error(NCBI::Document::NotFound)
      lambda { model_class.fetch(9876543210) }.should raise_error(NCBI::Document::NotFound)
    end
  end

  # Clicking link to get updates will refetch data.
  # Start object with attribute set to initial value.
  def it_can_be_refetched(attribute, initial_value)
    model_class = model_class()
    it 'can be refetched' do
      object = model_class.make_from_fixture_file(attribute => initial_value)
      stub_entrez_request_with_stubbed_response :EFetch, model_class.fixture_file.read
      visit url_for(object)
      click_link('Get updates')
      updated_value = model_class.from_fixture_file.send(attribute)
      page.should have_content(updated_value.to_s)
    end
  end

  # From the home page, perform a polymorphic search for a term.
  # Search term must match search term of fixture file.
  def it_can_polymorphically_search_for(model_class, options)
    it "can polymorphically search for #{model_class}" do
      visit '/'
      # Spec will stub search. If told not to, will just make the object from fixture file.
      if options[:stub] == false
        model_class.make_from_fixture_file
      else
        model_class.stubs(:search_NCBI).returns(model_class.search_ncbi_from_fixture_file)
      end
      submit_polymorphic_search_for model_class, options[:search_term]
      within '.attribute_table' do
        page.should have_content(options[:search_term])
      end
    end
  end

  def it_can_download_csv_of_list_of_ncbi_ids
    model_class = model_class()
    it 'can download CSV of list of NCBI ids' do
      ids = [1, 2]
      ids.each { |id| model_class.make(ncbi_id: id) }
      visit url_for(model_class, :index)
      fill_in :ids, with: ids.join("\n")
      click_button 'Download'
      page.body.should == model_class.with_ncbi_ids(ids).to_csv
    end
  end

  private

  def model_class
    # for request spec.
    description.singularize.classify.constantize
  end

end
