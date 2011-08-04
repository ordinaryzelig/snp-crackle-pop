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
    within '#main' do
      fill_in 'q', with: term
      click_button 'Search'
    end
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

end
