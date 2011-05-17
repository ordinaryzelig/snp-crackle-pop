module DescriptionMacros

  def it_parses_attribute(attribute, expected_value)
    it attribute do
      pending if expected_value == :pending
      @record.send(attribute).should == expected_value
    end
  end

end
