RSpec::Matchers.define :be_found_when_searching_for do |term|
  match do |object|
    object.class.search(term).should include(object)
  end
  failure_message_for_should do |object|
    "Searching for '#{term}' did not include object"
  end
end
