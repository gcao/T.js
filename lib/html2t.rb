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
      unless attrs_data.empty?
        if @options[:condense]
          if attrs_data['id']
            result[0] += '#' + attrs_data.delete('id')
          end
          if attrs_data['class']
            result[0] += '.' + attrs_data.delete('class').gsub(' ', '.')
          end
        end
        result << attrs_data unless attrs_data.empty?
      end
      node.children.each do |child|
        data = node_to_data(child)
        result << data if data
      end
      result
    when Nokogiri::XML::Node::TEXT_NODE
      text = node.text
      if text.strip.length > 0
        node.text
      end
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

