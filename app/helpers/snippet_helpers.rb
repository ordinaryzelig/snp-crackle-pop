SnpCracklePop.helpers do

  def row_for_attribute(object, attribute, options = {})
    partial 'shared/row_for_attribute', locals: {object: object, attribute: attribute, options: options}
  end

end
