require 'nokogiri'

class Html2t

  def initialize is_fragment = false
    @is_fragment = is_fragment
  end

  def parse_file file_name
    parse_string File.open(file_name).read
  end

  def parse_string html_string
    result = []
    klass = @is_fragment ? Nokogiri::HTML::DocumentFragment : Nokogiri::HTML::Document
    document = klass.parse html_string
    document.children.each do |node|
      node_data = node_to_data(node)
      result << node_data if node_data
    end
    result = result.first if result.size == 1 and result.first.is_a? Array
    result
  end

  def node_to_data node
    case node.node_type
    when Nokogiri::XML::Node::ELEMENT_NODE
      result = [node.name]
      attrs_data = attrs_to_data(node.attributes)
      result << attrs_data unless attrs_data.empty?
      node.children.each do |child|
        result << node_to_data(child)
      end
      result
    when Nokogiri::XML::Node::TEXT_NODE
      node.text
    when Nokogiri::XML::Node::COMMENT_NODE
      "<!--#{node.text}-->"
    end
  end

  def attrs_to_data attrs
    result = {}
    attrs.each do |name, attr|
      result[name] = attr.value
    end
    result
  end

end

