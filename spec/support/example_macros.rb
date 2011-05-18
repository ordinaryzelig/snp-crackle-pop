module ExampleMacros

  def drop_tables
    Mongoid.master.collections.select do |collection|
      collection.name !~ /system/
    end.each(&:drop)
  end

  def fixture_file(file_name)
    File.open(Padrino.root + '/spec/support/fixtures/' + file_name)
  end

  # Generic steps to search for a term.
  # Assumes there is a form with a text field named 'q'
  # and a Search button.
  def submit_search_for(term)
    fill_in 'q', with: term
    click_button 'Search'
  end

  def submit_polymorphic_search_for(object, attribute_to_search)
    fill_in 'q', with: object.send(attribute_to_search)
    select object.class.humanize, from: 'Database'
    click_button 'Search'
  end

  def saop
    save_and_open_page
  end

  # Delegate to SnpCracklePop.
  def url(*args)
    SnpCracklePop.url(*args)
  end

  # Polymorphic url generator.
  def url_for(object, action = :show)
    url(object.class.name.tableize.to_sym, action, id: object.ncbi_id)
  end

end
