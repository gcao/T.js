require 'nokogiri'

class Html2t

  def self.parse html, options = {}
    new(options).parse html
  end

  def self.parse_file file, options = {}
    new(options).parse_file file
  end

  def initialize options = {}
    @options = options
  end

  def parse_file file_name
    parse File.open(file_name).read
  end

  def parse html
    result = []
    klass = @options[:fragment] ? Nokogiri::HTML::DocumentFragment : Nokogiri::HTML::Document
    document = klass.parse html
    document.children.each do |node|
      node_data = node_to_data(node)
      result << node_data if node_data
    end
    result = result.first if result.size == 1 and result.first.is_a? Array
    result
  end

  private

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

