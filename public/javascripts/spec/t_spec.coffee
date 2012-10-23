describe "T.utils.normalize", ->
  it "should normalize array", ->
    input  = ['div', ['', 'text']]
    output = ['div', 'text']
    expect(T.utils.normalize(input)).toEqual(output)
