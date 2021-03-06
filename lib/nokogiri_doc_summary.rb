# Extend a nokogiri node with convenience methods that parse an Entrez DocSummary.
# node.items returns hash with name of item as key and content as value.
# Value is type cast depending on 'Type' attribute.
# Nokogiri::Node.to_s should look like this:
# <DocSum>
#   <Item Name="something" Type="Integer">123</Item>
#   ...
# </DocSum>

module NokogiriDocSummary

  def items
    css('Item').each_with_object({}) do |item_node, hash|
      value = item_node.content
      case item_node['Type']
      when 'Integer'
        value = value.to_i
      end
      hash[item_node['Name']] = value
    end
  end

end
