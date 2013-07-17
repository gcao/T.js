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

describe "T.def/use", ->
  it "should work", ->
    T.def('template', (data) -> ['div', data])
    result   = ['div', 'value']
    expect(T.use('template').process('value')).toEqual(result)

  it "redef should work", ->
    T.def('template', (data) -> ['div', data])
    T.redef('template', (data) -> ['div.container', T.wrapped(data)])
    result   = [
      "div"
      class: 'container'
      ['div', 'value']
    ]
    expect(T.use('template').process('value')).toEqual(result)

describe "T.escape", ->
  it "should work", ->
    expect(T.escape('<>&<>&')).toEqual('&lt;&gt;&amp;&lt;&gt;&amp;')

describe "T.unescape", ->
  it "should work", ->
    expect(T.unescape('&lt;&gt;&amp;&lt;&gt;&amp;')).toEqual('<>&<>&')

describe "T()", ->
  it "process should work", ->
    T.def('template', (data) -> ["div", data.name])
    data = name: 'John Doe'
    expect(T('template').process(data)).toEqual(['div', 'John Doe'])

  it "process([]) should work", ->
    T.def('template', [])
    expect(T('template').process()).toEqual([])

  it "T(template, data) should call process", ->
    T.def('template', (data) -> ["div", data.name])
    data = name: 'John Doe'
    expect(T('template', data)).toEqual(['div', 'John Doe'])

  it "include template as partial should work", ->
    T.def('partial', (data) -> ["div", data.name])
    T.def('template', (data) -> ["div", T('partial', data.account)])
    data   = account: name: 'John Doe'
    result = ['div', ['div', 'John Doe']]
    expect(T('template', data)).toEqual(result)

  it "complex template should work", ->
    T.def('profileTemplate', (data) -> ['div', data.username])
    T.def('accountTemplate', (data) -> ['div', data.name, T('profileTemplate', data.profile)])
    T.def('template', (data) -> ['div', T('accountTemplate', data.account)])
    result          = ['div'
      [ 'div'
        'John Doe'
        ['div', 'johndoe']
      ]
    ]
    data =
      account:
        name: 'John Doe'
        profile:
          username: 'johndoe'
    expect(T('template', data)).toEqual(result)

describe "T().prepare/T.include", ->
  it "should work", ->
    T.def('template', (data) -> ['div', T.include('title', data)])
    partial = (data) -> ['div', data.name]
    expect(T('template').prepare(title: partial).process(name: 'John Doe')).toEqual(['div', ['div', 'John Doe']])

  it "nested include/prepare should work", ->
    T.def('template', ['div', T.include('title')])
    T.def('template2', ['div', T('template').prepare(title: 'Title'), T.include('body')])
    expect(T('template2').prepare(body: 'Body').process()).toEqual(['div', ['div', 'Title'], 'Body'])

describe "T.noConflict", ->
  it "should work", ->
    T1 = T.noConflict()
    expect(typeof T).toEqual('undefined')
    THIS.T = T1

