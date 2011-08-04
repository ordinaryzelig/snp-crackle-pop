RSpec::Matchers.define :be_found_when_searching_NCBI_for do |term|
  match do |object|
    search_results = object.class.search(term)
    search_results.map(&:ncbi_id).include?(object.ncbi_id)
  end
  failure_message_for_should do |object|
    "Searching for '#{term}' did not include NCBI ID #{object.ncbi_id}"
  end
end

RSpec::Matchers.define :have_attributes do |atts|
  match do |object|
    atts.all? do |attribute, value|
      @attribute = attribute
      @expected_value = value
      @actual_value = object.send(attribute)
      @actual_value == @expected_value
    end
  end
  failure_message_for_should do |object|
    "Expected #{object.class}##{@attribute} to be '#{@expected_value}' but was '#{@actual_value}'"
  end
end

RSpec::Matchers.define :be_valid_to_search do |model_class|
  match do |term|
    model_class::SearchRequest.new(term).should be_valid
  end
  failure_message_for_should do |term|
    "Expected '#{term}' to be valid for #{model_class}::SearchRequest"
  end
  failure_message_for_should_not do |term|
    "Expected '#{term}' to not be valid for #{model_class}::SearchRequest"
  end
end

# Custom matcher that compares the response of an NCBI Document model to a given string.
# A failure most likely means that the data from NCBI has been updated,
# and the fixture file needs to be updated as well.
# If the comparison takes too long, just give up and fail the test.
# Failure ouputs actual string for easy copy/paste.
RSpec::Matchers.define :match_xml_response_with do |expected_string|
  match do |model|
    begin
      @actual_string = model.response.body.chomp
      timeout(2.seconds) { @actual_string.should == expected_string.chomp }
    rescue Timeout::Error
      false
    end
  end
  failure_message_for_should do |model|
    puts @actual_string
    "#{model.class} response did not match given string."
  end
end
