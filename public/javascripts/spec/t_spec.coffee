describe "T.utils.processFirst", ->
  it "should parse div#this.class1.class2", ->
    input  = ['div#this.class1.class2', 'text']
    result = ['div', {id: 'this', 'class': 'class1 class2'}, 'text']
    expect(T.utils.processFirst(input)).toEqual(result)

  it "should parse div#this", ->
    input  = ['div#this', 'text']
    result = ['div', {id: 'this'}, 'text']
    expect(T.utils.processFirst(input)).toEqual(result)

  it "should parse 'div#this div.child'", ->
    input  = ['div#this div.child', 'text']
    result = ['div', {id: 'this'}, ['div', {'class': 'child'}, 'text']]
    expect(T.utils.processFirst(input)).toEqual(result)

  it "should return as is if first starts with '<'", ->
    input  = ['<!DOCTYPE html>', '...']
    result = input
    expect(T.utils.processFirst(input)).toEqual(result)

  it "should return as is if first is an array", ->
    input  = [[], '...']
    result = input
    expect(T.utils.processFirst(input)).toEqual(result)

describe "T.utils.normalize", ->
  it "should normalize array", ->
    input  = ['div', ['', 'text']]
    result = ['div', 'text']
    expect(T.utils.normalize(input)).toEqual(result)

  it "should normalize array if first item is an array", ->
    input  = ['div', [['div'], 'text']]
    result = ['div', ['div'], 'text']
    expect(T.utils.normalize(input)).toEqual(result)

  it "should normalize array recursively", ->
    input  = ['div', ['', 'text', ['', 'text2']]]
    result = ['div', 'text', 'text2']
    expect(T.utils.normalize(input)).toEqual(result)

describe "T.utils.parseStyles", ->
  it "should parse styles", ->
    input  = "a:a-value;b:b-value;"
    result = {a: 'a-value', b: 'b-value'}
    expect(T.utils.parseStyles(input)).toEqual(result)

describe "T.utils.processStyles", ->
  it "should work", ->
    input  = {style: 'a:a-value;b:b-value;', styles: {c: 'c-value'}}
    result = {style: {a: 'a-value', b: 'b-value', c: 'c-value'}}
    expect(T.utils.processStyles(input)).toEqual(result)

describe "T.utils.processAttributes", ->
  it "should merge attributes", ->
    input  = ['div', {a: 1}, {a: 11, b: 2}]
    result = ['div', {a: 11, b: 2}]
    expect(T.utils.processAttributes(input)).toEqual(result)

  it "should merge attributes and keep other items untouched", ->
    input  = ['div', {a: 1}, 'first', {b: 2}, 'second']
    result = ['div', {a: 1, b: 2}, 'first', 'second']
    expect(T.utils.processAttributes(input)).toEqual(result)

  it "should merge styles", ->
    input  = ['div', {style: 'a:old-a;b:b-value;', styles: {c: 'c-value'}}, {style: 'a:new-a'}]
    result = ['div', {style: {a: 'new-a', b: 'b-value', c: 'c-value'}}]
    expect(T.utils.processAttributes(input)).toEqual(result)

  it "should merge css classes", ->
    input  = ['div', {'class': 'first second'}, {'class': 'third'}]
    result = ['div', {'class': 'first second third'}]
    expect(T.utils.processAttributes(input)).toEqual(result)

describe "T.process", ->
  it "should create ready-to-be-rendered data structure from template and data", ->
    template = [
      'div#test'
      {'class': 'first second'}
      {'class': 'third'}
    ]
    result = [
      'div'
      id: 'test'
      'class': 'first second third'
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
      {'class': 'first second'}
      {'class': 'third'}
    ]
    result = '<div id="test" class="first second third"/>'
    expect(T.render(template)).toEqual(result)

describe "T.value", ->
  it "should work", ->
    v    = T.value('name')
    data = name: 'John Doe'
    expect(v(data)).toEqual(data.name)

  it "should work with nested attribute", ->
    v    = T.value('account.name')
    data = account: name: 'John Doe'
    expect(v(data)).toEqual(data.account.name)

  it "Should take default value", ->
    v = T.value('name', 'Default')
    expect(v()).toEqual('Default')

describe "T.escape", ->
  it "should work", ->
    expect(T.escape('<>&')).toEqual('&lt;&gt;&amp;')

describe "T.unescape", ->
  it "should work", ->
    expect(T.unescape('&lt;&gt;&amp;')).toEqual('<>&')

describe "T()", ->
  it "T(T()) should return same Template object", ->
    t  = T("div", "text")
    t1 = T(t)
    expect(t1).toEqual(t)

  it "process should work", ->
    template = ["div", (data) -> data.name]
    mapper   = (data) -> data.account
    t        = T(template).map(mapper)
    data     = account: name: 'John Doe'
    expect(t.process(data)).toEqual(['div', 'John Doe'])

  it "include template as partial should work", ->
    partial  = ["div", (data) -> data.name]
    template = ["div", T(partial).map((data) -> data.account)]
    result   = ['div', ['div', 'John Doe']]
    expect(T(template).process({account: {name: 'John Doe'}})).toEqual(result)

  it "include template as partial should work", ->
    partial  = ["div", T.value('name')]
    template = ["div", T(partial).map((data) -> data.account)]
    result   = '<div><div>John Doe</div></div>'
    expect(T(template).render({account: {name: 'John Doe'}})).toEqual(result)

  it "data is empty", ->
    template = ["div", (data) -> data?.name]
    mapper   = (data) -> data?.account
    t        = T(template).map(mapper)
    expect(t.process()).toEqual(['div', undefined])

describe "T.prepare/T.include", ->
  it "should work", ->
    template = -> ['div', T.include('title')]
    expect(T.prepare(template, title: 'Title').process()).toEqual(['div', 'Title'])

  it "include2/prepare2 should work", ->
    template = -> ['div', T.include2(), T.include('content')]
    expect(T.prepare2(template, 'Title', content: 'Content').process()).toEqual(['div', 'Title', 'Content'])

  it "nested include/prepare should work", ->
    template  = -> ['div', T.include('title')]
    template2 = -> ['div', T.prepare(template, title: 'Title'), T.include('body')]
    expect(T.prepare(template2, body: 'Body').process()).toEqual(['div', ['div', 'Title'], 'Body'])

  it "include can take default value", ->
    template = -> ['div', T.include('title', 'Default Title')]
    expect(T.prepare(template).process()).toEqual(['div', 'Default Title'])

describe "T().prepare/T.include", ->
  it "should work", ->
    template = T(['div', T.include('title')])
    expect(template.prepare(title: 'Title').process()).toEqual(['div', 'Title'])

  it "prepare2 should work", ->
    template = T(['div', T.include2(), T.include('title')])
    expect(template.prepare2('first', title: 'Title').process()).toEqual(['div', 'first', 'Title'])

  it "nested include/prepare should work", ->
    template  = T(['div', T.include('title')])
    template2 = T(['div', template.prepare(title: 'Title'), T.include('body')])
    expect(template2.prepare(body: 'Body').process()).toEqual(['div', ['div', 'Title'], 'Body'])

  it "mapper should work", ->
    layout   = T(['div', T.include('title')])
    partial  = (data) -> data.title
    template = layout.prepare(title: partial)
    expect(template.process(title: 'Title')).toEqual(['div', 'Title'])

