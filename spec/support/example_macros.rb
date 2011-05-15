module ExampleMacros

  def drop_tables
    Mongoid.master.collections.select do |collection|
      collection.name !~ /system/
    end.each(&:drop)
  end

  def fixture_file(file_name)
    File.open(Padrino.root + '/spec/fixtures/' + file_name)
  end

  def search_for_rs_number(rs_number)
    fill_in 'Rs number', with: rs_number
    click_button 'Search'
  end

end
