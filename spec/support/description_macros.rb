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

end
