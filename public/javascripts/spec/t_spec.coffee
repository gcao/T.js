# Save a reference of "this", will be used later
THIS = this

describe "T.internal.processFirst", ->
  it "should parse div#this.class1.class2", ->
    input  = ['div#this.class1.class2', 'text']
    result = ['div', {id: 'this', 'class': 'class1 class2'}, 'text']
    expect(T.internal.processFirst(input)).toEqual(result)

  it "should parse div#this", ->
    input  = ['div#this', 'text']
    result = ['div', {id: 'this'}, 'text']
    expect(T.internal.processFirst(input)).toEqual(result)

  it "should parse 'div#this div.child'", ->
    input  = ['div#this div.child', 'text']
    result = ['div', {id: 'this'}, ['div', {class: 'child'}, 'text']]
    expect(T.internal.processFirst(input)).toEqual(result)

  it "should return as is if first starts with '<'", ->
    input  = ['<!DOCTYPE html>', '...']
    result = input
    expect(T.internal.processFirst(input)).toEqual(result)

  it "should return as is if first is an array", ->
    input  = [[], '...']
    result = input
    expect(T.internal.processFirst(input)).toEqual(result)

describe "T.internal.normalize", ->
  it "should normalize array", ->
    input  = ['div', ['', 'text']]
    result = ['div', 'text']
    expect(T.internal.normalize(input)).toEqual(result)

  it "should normalize array if first item is an array", ->
    input  = ['div', [['div'], 'text']]
    result = ['div', ['div'], 'text']
    expect(T.internal.normalize(input)).toEqual(result)

  it "should normalize array recursively", ->
    input  = ['div', ['', 'text', ['', 'text2']]]
    result = ['div', 'text', 'text2']
    expect(T.internal.normalize(input)).toEqual(result)

describe "T.internal.parseStyles", ->
  it "should parse styles", ->
    input  = "a:a-value;b:b-value;"
    result = {a: 'a-value', b: 'b-value'}
    expect(T.internal.parseStyles(input)).toEqual(result)

describe "T.internal.processStyles", ->
  it "should work", ->
    input  = {style: 'a:a-value;b:b-value;'}
    result = {style: {a: 'a-value', b: 'b-value'}}
    expect(T.internal.processStyles(input)).toEqual(result)

describe "T.internal.processAttributes", ->
  it "should merge attributes", ->
    input  = ['div', {a: 1}, {a: 11, b: 2}]
    result = ['div', {a: 11, b: 2}]
    expect(T.internal.processAttributes(input)).toEqual(result)

  it "should merge attributes and keep other items untouched", ->
    input  = ['div', {a: 1}, 'first', {b: 2}, 'second']
    result = ['div', {a: 1, b: 2}, 'first', 'second']
    expect(T.internal.processAttributes(input)).toEqual(result)

  it "should merge styles", ->
    input  = ['div', {style: 'a:old-a;b:b-value;'}, {style: 'a:new-a'}]
    result = ['div', {style: {a: 'new-a', b: 'b-value'}}]
    expect(T.internal.processAttributes(input)).toEqual(result)

  it "should merge css classes", ->
    input  = ['div', {class: 'first second'}, {class: 'third'}]
    result = ['div', {class: 'first second third'}]
    expect(T.internal.processAttributes(input)).toEqual(result)

describe "T.process", ->
  it "should create ready-to-be-rendered data structure from template and data", ->
    template = [
      'div#test'
      {class: 'first second'}
      {class: 'third'}
    ]
    result = [
      'div'
      id: 'test'
      class: 'first second third'
    ]
    expect(T.process(template)).toEqual(result)

  it "can be called with different data", ->
    template = ['div', (data) -> data ]
    expect(T.process(template, 'test')).toEqual(['div', 'test'])
    expect(T.process(template, 'test1')).toEqual(['div', 'test1'])

describe "T.render", ->
  it "should work", ->
    template = ['div', 'a', 'b']
    result   = '<div>ab</div>'
    expect(T.render(template)).toEqual(result)

  it "should work", ->
    template = [['div', 'a'], ['div', 'b']]
    result   = '<div>a</div><div>b</div>'
    expect(T.render(template)).toEqual(result)

  it "empty script should not self-close", ->
    template = ['script']
    result   = '<script></script>'
    expect(T.render(template)).toEqual(result)

  it "script should not self-close", ->
    template = ['script', src: 'test.js']
    result   = '<script src="test.js"></script>'
    expect(T.render(template)).toEqual(result)

  it "should render template", ->
    template = [
      'div#test'
      {class: 'first second'}
      {class: 'third'}
    ]
    result = '<div id="test" class="first second third"/>'
    expect(T.render(template)).toEqual(result)

describe "T.get", ->
  it "should work", ->
    v    = T.get('name')
    data = name: 'John Doe'
    expect(v(data)).toEqual(data.name)

  it "should work with nested attribute", ->
    v    = T.get('account.name')
    data = account: name: 'John Doe'
    expect(v(data)).toEqual(data.account.name)

  it "Should take default value", ->
    v = T.get('name', 'Default')
    expect(v()).toEqual('Default')

describe "T.escape", ->
  it "should work", ->
    expect(T.escape('<>&<>&')).toEqual('&lt;&gt;&amp;&lt;&gt;&amp;')

describe "T.unescape", ->
  it "should work", ->
    expect(T.unescape('&lt;&gt;&amp;&lt;&gt;&amp;')).toEqual('<>&<>&')

describe "T.if", ->
  it "should work", ->
    template = (cond) -> ['div', T.if(cond, 'true')]
    result   = ['div', 'true']
    expect(T(template).process(true)).toEqual(result)

  it "should work if condition evals to false", ->
    template = (cond) -> ['div', T.if(cond, 'true', 'false')]
    result   = ['div', 'false']
    expect(T(template).process(false)).toEqual(result)

  it "condition function should work", ->
    template = (data) -> ['div', T.if(((data) -> data.cond), 'true', 'false')]
    expect(T(template).process(cond: true)).toEqual(['div', 'true'])
    expect(T(template).process(cond: false)).toEqual(['div', 'false'])

describe "T.for", ->
  it "should work", ->
    template = (data) -> T.for(data, (item, i, count) -> ['div', item])
    result   = [
      ['div', 'item1']
      ['div', 'item2']
    ]
    expect(T(template).process(['item1', 'item2'])).toEqual(result)

describe "T()", ->
  it "T(T()) should return same Template object", ->
    template = T(["div", "text"])
    expect(T(template)).toEqual(template)

  it "process should work", ->
    template = ["div", (data) -> data.name]
    mapper   = (data) -> data.account
    t        = T(template).map(mapper)
    data     = account: name: 'John Doe'
    expect(t.process(data)).toEqual(['div', 'John Doe'])

  it "each should work", ->
    template = (data) ->
      ['div', data]
    result = [
      ['div', 'a']
      ['div', 'b']
    ]
    expect(T(template).each().process(['a', 'b'])).toEqual(result)

  it "each with a mapper should work", ->
    template = (data) ->
      ['div', data]
    result = [
      ['div', 'a']
      ['div', 'b']
    ]
    expect(T(template).each((data) -> data.items).process(items: ['a', 'b'])).toEqual(result)

  it "each & T.index() & T.count() should work", ->
    template = (data) ->
      ['div', T.index(), data, T.count()]
    result = [
      ['div', 0, 'a', 2]
      ['div', 1, 'b', 2]
    ]
    expect(T(template).each().process(['a', 'b'])).toEqual(result)

  it "include template as partial should work", ->
    partial  = ["div", (data) -> data.name]
    template = ["div", T(partial).map((data) -> data.account)]
    result   = ['div', ['div', 'John Doe']]
    expect(T(template).process(account: name: 'John Doe')).toEqual(result)

  it "include template as partial should work", ->
    partial  = ["div", T.get('name')]
    template = ["div", T(partial).map((data) -> data.account)]
    result   = '<div><div>John Doe</div></div>'
    expect(T(template).render(account: name: 'John Doe')).toEqual(result)

  it "data is empty", ->
    template = ["div", (data) -> data?.name]
    mapper   = (data) -> data?.account
    t        = T(template).map(mapper)
    expect(t.process()).toEqual(['div', undefined])

describe "T().prepare/T.include", ->
  it "should work", ->
    template = ['div', T.include('title')]
    expect(T(template).prepare(title: 'Title').process()).toEqual(['div', 'Title'])

  it "should work with partial", ->
    template = ['div', T.include('title')]
    partial  = ['div', (data) -> data.name ]
    expect(T(template).prepare(title: partial).process(name: 'John Doe')).toEqual(['div', ['div', 'John Doe']])

  it "prepare2 should work", ->
    template = ['div', T.include2(), T.include('title')]
    expect(T(template).prepare2('first', title: 'Title').process()).toEqual(['div', 'first', 'Title'])

  it "nested include/prepare should work", ->
    template  = ['div', T.include('title')]
    template2 = ['div', T(template).prepare(title: 'Title'), T.include('body')]
    expect(T(template2).prepare(body: 'Body').process()).toEqual(['div', ['div', 'Title'], 'Body'])

  it "mapper should work", ->
    layout   = ['div', T.include('title')]
    partial  = (data) -> data.title
    template = T(layout).prepare(title: partial).map((data) -> data.main)
    expect(template.process(main: title: 'Title')).toEqual(['div', 'Title'])

describe "T.noConflict", ->
  it "should work", ->
    T1 = T.noConflict()
    expect(typeof T).toEqual('undefined')
    THIS.T = T1

  it "pass reference to T in closure", ->
    T1 = T.noConflict()
    ((T) ->
      template = (data) -> ["div", T.index(), data]
      result   = [['div', 0, 'item1'], ['div', 1, 'item2']]
      expect(T(template).each().process(['item1', 'item2'])).toEqual(result)
    )(T1)
    THIS.T = T1

