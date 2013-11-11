require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

require 'html2t'

describe "html2t" do
  it "should work" do
    input = '<html><!-- comment --><body class="blue-theme">Text goes here</body><html>'
    output = [
      "html",
      "<!-- comment -->",
      ["body",
        {'class' => 'blue-theme'},
        "Text goes here"
      ]
    ]
    Html2t.parse(input).should eql(output)
  end

  it "should append id and classes to tag if condense option is true" do
    input = '<html><!-- comment --><body id="main" class="blue-theme">Text goes here</body><html>'
    output = [
      "html",
      "<!-- comment -->",
      ["body#main.blue-theme",
        "Text goes here"
      ]
    ]
    Html2t.parse(input, condense: true).should eql(output)
  end

  it "should work on file" do
    file = "/tmp/html2t.html"
    File.open(file, 'w') do |f|
      f.print '<html><!-- comment --><body class="blue-theme">Text goes here</body><html>'
    end

    output = [
      "html",
      "<!-- comment -->",
      ["body",
        {'class' => 'blue-theme'},
        "Text goes here"
      ]
    ]

    Html2t.parse_file(file).should eql(output)
  end
end

