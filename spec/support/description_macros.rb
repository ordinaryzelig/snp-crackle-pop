module DescriptionMacros

  def it_parses_attribute(attribute, expected_value)
    it attribute do
      pending if expected_value == :pending
      @record.send(attribute).should == expected_value
    end
  end

  def it_has_taxonomy
    model = description.constantize
    it 'should return taxonomy object for tax_id' do
      record = model.from_fixture_file
      taxonomy = record.taxonomy
      taxonomy.should_not be_nil
      taxonomy.should eq(Taxonomy.first)
    end
  end

end
