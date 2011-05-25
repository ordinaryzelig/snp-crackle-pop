RSpec::Matchers.define :be_found_when_searching_for do |term|
  match do |object|
    object.class.search(term).should include(object)
  end
  failure_message_for_should do |object|
    "Searching for '#{term}' did not include object"
  end
end

RSpec::Matchers.define :have_attributes do |atts|
  match do |object|
    atts.each do |attribute, value|
      @attribute = attribute
      @expected_value = value
      @actual_value = object.send(attribute)
      @actual_value.should == @expected_value
    end
  end
  failure_message_for_should do |object|
    "Expected #{object.class}##{@attribute} to be '#{@expected_value}' but was '#{@actual_value}'"
  end
end
