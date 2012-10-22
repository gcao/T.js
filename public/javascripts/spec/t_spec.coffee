describe "T.utils.normalize", ->
  it "should normalize array", ->
    input  = []
    output = []
    expect(T.utils.normalize(input)).toEqual(output)
