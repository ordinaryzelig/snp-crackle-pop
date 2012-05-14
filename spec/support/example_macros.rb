module ExampleMacros

  def drop_tables
    Mongoid.master.collections.select do |collection|
      collection.name !~ /system/
    end.each(&:drop)
  end

  def fixture_file(file_name)
    File.open(Padrino.root + '/spec/support/fixtures/' + file_name)
  end

  def fixture_file_content(file_name)
    fixture_file(file_name).read
  end

  def fill_in_fields(fields_and_values)
    fields_and_values.each do |field, value|
      fill_in field.to_s, with: value
    end
  end

  # Generic steps to search for a term.
  # Assumes there is a form with a text field named 'q'
  # and a Search button.
  def submit_search_for(term)
    within '#main' do
      fill_in_fields 'q' => term
      click_button 'Search'
    end
  end

  def submit_location_search_for(terms)
    formatted_terms = terms.each_with_object({}) { |(field, value), new| new["location[#{field}]"] = value }
    fill_in_fields(formatted_terms)
    click_button 'Locate'
  end

  def submit_polymorphic_search_for(model_class, term)
    within '#menu_bar' do
      fill_in 'q', with: term
      select model_class.humanize, from: 'database'
      click_button 'Search'
    end
  end

  def saop
    save_and_open_page
  end

  # Delegate to SnpCracklePop.
  def url(*args)
    SnpCracklePop.url(*args)
  end

  # Polymorphic url generator.
  def url_for(object, action = :show, params = {})
    parameters = params
    if object.is_a?(Mongoid::Document)
      model_class = object.class
      parameters[:id] ||= object.ncbi_id
    else
      model_class = object
    end
    url(model_class.name.tableize.to_sym, action, parameters)
  end

  # Use FakeWeb to simulate Entrez service with fakeweb options (mainly the :body options).
  # Since the generated URL is a bit difficult to capture,
  # Faked uri will just match regular expression of service.
  # When block ends, clean registry.
  def fake_service(service, options, &block)
    FakeWeb.register_uri(:get, Regexp.new(service.to_s.downcase), options.merge(content_type: 'text/xml'))
    block.call
  ensure
    FakeWeb.clean_registry
  end

  def fake_service_with_file(service, file, &block)
    file_content = file.read
    file.rewind
    fake_service(service, body: file_content, &block)
  end

  # Fake ESearch with nothing, fake ESummary with file contents.
  def fake_search_request(file, &block)
    fake_service_with_file :ESearch, fixture_file('empty_esearch.xml') do
      fake_service_with_file :ESummary, file, &block
    end
  end

  # Bad hack to prevent fetching snp associations.
  # This happens when a test is already heavily invested in faking requests that
  # it cannot easily add another to fetch snp associations.
  def disable_snp_associations
    Snp.any_instance.stubs(:fetch_associations)
  end

end
