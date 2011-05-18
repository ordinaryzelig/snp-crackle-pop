SnpCracklePop.helpers do

  def row_for_attribute(object, attribute, options = {}, &block)
    if block_given?
      options[:content] = capture_haml &block
    end
    partial 'shared/row_for_attribute', locals: {object: object, attribute: attribute, options: options}
  end

  def row_for_updated_from_NCBI_at(object)
    partial 'shared/row_for_updated_from_NCBI_at', locals: {object: object}
  end

end
