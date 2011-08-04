SnpCracklePop.helpers do

  def row_for_attribute(object, attribute, options = {}, &block)
    if block_given?
      options[:content] = capture_haml &block
    end
    options[:content] ||= '(pending)' if options[:pending]
    partial 'shared/row_for_attribute', locals: {object: object, attribute: attribute, options: options}
  end

  def row_for_updated_from_ncbi_at(object)
    partial 'shared/row_for_updated_from_ncbi_at', locals: {object: object}
  end

  def row_for_taxonomy(object)
    partial 'shared/row_for_taxonomy', locals: {object: object}
  end

  def search_field_tag(name, options = {})
    input_tag :search, options.reverse_merge!(name: name)
  end

  def title(page_title)
    content_for(:title) { truncate(page_title, length: 40) }
  end

  def download_partial(model_class)
    partial 'shared/download', locals: {model_class: model_class}
  end

end
