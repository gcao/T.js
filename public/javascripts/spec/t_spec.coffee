describe "T.utils.normalize", ->
  it "should normalize array", ->
    #a = ['a', 'b']
    #b = [1, 2, 3]
    #b.splice(1, 1, a...)
    #console.log b

    input  = ['div', ['', 'text']]
    output = ['div', 'text']
    expect(T.utils.normalize(input)).toEqual(output)
