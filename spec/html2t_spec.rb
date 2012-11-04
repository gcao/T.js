require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

require 'html2t'

describe "html2t" do
  it "should work" do
    input = '<html><!-- comment --><body class="blue-theme">Text goes here</body><html>'
    output = [
      "html",
      "<!-- comment -->",
      ["body",
        {:class => 'blue-theme'},
        "Text goes here"
      ]
    ]
    Html2t.parse_html(input).should eql(output)
  end
end

