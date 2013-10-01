# Save a reference of "this", will be used later
THIS = this

describe "T.internal.processFirst", ->
  it "should parse div#this.class1.class2.class3", ->
    input  = ['div#this.class1.class2.class3', 'text']
    result = ['div', {id: 'this', 'class': 'class1 class2 class3'}, 'text']
    expect(T.internal.processFirst(input)).toEqual(result)

  it "should parse div#this", ->
    input  = ['div#this', 'text']
    result = ['div', {id: 'this'}, 'text']
    expect(T.internal.processFirst(input)).toEqual(result)

  it "should parse #this", ->
    input  = ['#this', 'text']
    result = ['div', {id: 'this'}, 'text']
    expect(T.internal.processFirst(input)).toEqual(result)

  it "should parse 'div#this div.child'", ->
    input  = ['div#this div.child', 'text']
    result = ['div', {id: 'this'}, ['div', {class: 'child'}, 'text']]
    expect(T.internal.processFirst(input)).toEqual(result)

  it "should parse '.tb-item.refresh a.toggle-opacity'", ->
    input  = ['.tb-item.refresh a.toggle-opacity', 'text']
    result = ['div', {class: 'tb-item refresh'}, ['a', {class: 'toggle-opacity'}, 'text']]
    expect(T.internal.processFirst(input)).toEqual(result)

  it "should parse nested '.tb-item.refresh a.toggle-opacity'", ->
    input  = ['div', ['.tb-item.refresh a.toggle-opacity', 'text']]
    result = ['div', ['div', {class: 'tb-item refresh'}, ['a', {class: 'toggle-opacity'}, 'text']]]
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
  it "should return empty array as is", ->
    input  = []
    result = []
    expect(T.internal.processAttributes(input)).toEqual(result)

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

describe "T.internal.renderAttributes", ->
  it "should work", ->
    input  = {style: top: 10}
    result = ' style="top:10px;"'
    expect(T.internal.renderAttributes(input)).toEqual(result)

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
    expect(T.process(template).tags).toEqual(result)

  it "should work with multiple arguments", ->
    template = (arg1, arg2, arg3) -> ["div", arg1, arg2, arg3]
    result = ['div', '1', '2', '3']
    expect(T.process(template, '1', '2', '3').tags).toEqual(result)

  it "can be called with different data", ->
    template = (data) -> ['div', data ]
    expect(T.process(template, 'test' ).tags).toEqual(['div', 'test'])
    expect(T.process(template, 'test1').tags).toEqual(['div', 'test1'])

describe "T.def", ->
  it "should work", ->
    T.def('template', (data) -> ['div', data])
    result   = ['div', 'value']
    expect(T('template').process('value').tags).toEqual(result)

  it "redef should work", ->
    T.def('template', (data) -> ['div', data])
    T.redef('template', (data) -> ['div.container', T.wrapped(data)])
    result   = [
      "div"
      class: 'container'
      ['div', 'value']
    ]
    expect(T('template').process('value').tags).toEqual(result)

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
    expect(T('template').process(data).tags).toEqual(['div', 'John Doe'])

  it "process with multiple arguments should work", ->
    T.def('template', (arg1, arg2, arg3) -> ["div", arg1, arg2, arg3])
    result = ['div', '1', '2', '3']
    expect(T('template').process('1', '2', '3').tags).toEqual(result)

  it "render with multiple arguments should work", ->
    T.def('template', (arg1, arg2, arg3) -> ["div", arg1, arg2, arg3])
    result = '<div>123</div>'
    expect(T('template', '1', '2', '3').toString()).toEqual(result)

  it "T(template, data) should call process with all arguments", ->
    T.def('template', (arg1, arg2) -> ["div", arg1, arg2])
    expect(T('template', '1', '2').tags).toEqual(['div', '1', '2'])

  it "T(template, data) should call process", ->
    T.def('template', (data) -> ["div", data.name])
    data = name: 'John Doe'
    expect(T('template', data).tags).toEqual(['div', 'John Doe'])

  it "include template as partial should work", ->
    T.def('partial', (data) -> ["div", data.name])
    T.def('template', (data) -> ["div", T('partial', data.account)])
    data   = account: name: 'John Doe'
    result = ['div', ['div', 'John Doe']]
    expect(T('template', data).tags).toEqual(result)

  it "complex template should work", ->
    T.def('profileTemplate', (data) -> ['div', data.username])
    T.def('accountTemplate', (data) -> ['div', data.name, T('profileTemplate', data.profile)])
    T.def('template', (data) -> ['div', T('accountTemplate', data.account)])
    result = ['div'
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
    expect(T('template', data).tags).toEqual(result)

describe "T().prepare/T.include", ->
  it "should work", ->
    T.def('template', (data) -> ['div', T.include('title', data)])
    partial = (data) -> ['div', data.name]
    expect(T('template').prepare(title: partial).process(name: 'John Doe').tags).toEqual(['div', ['div', 'John Doe']])

  it "layout can be reused", ->
    T.def('layout', -> ['div', T.include('body')])
    template1 = T('layout').prepare(body: 'Body1')
    template2 = T('layout').prepare(body: 'Body2')
    expect(template1.process().tags).toEqual(['div', 'Body1'])
    expect(template2.process().tags).toEqual(['div', 'Body2'])

  it "nested include/prepare should work", ->
    T.def('template' , -> ['div', T.include('title')])
    T.def('template2', -> ['div', T('template').prepare(title: 'Title').process(), T.include('body')])
    result = ['div', ['div', 'Title'], 'Body']
    expect(T('template2').prepare(body: 'Body').process().tags).toEqual(result)

describe "Clone T to avoid template conflicting", ->
  it "should work", ->
    T1 = T.create()
    T2 = T.create()
    T1.def('template', 'T1')
    T2.def('template', 'T2')
    expect(T1('template').process().tags).toEqual('T1')
    expect(T2('template').process().tags).toEqual('T2')

  it "should work with complex templates", ->
    T1 = T.create()
    T2 = T.create()
    T1.def('template', (data) -> ['div', T1.include('body', data)])
    T2.def('template', (arg1, arg2) -> ['div', arg1, arg2])
    expect(T1('template').prepare(body: (data) -> ['div', data]).process('John Doe').tags).toEqual(['div', ['div', 'John Doe']])
    expect(T2('template').process('1', '2').tags).toEqual(['div', '1', '2'])

describe "T.noConflict", ->
  it "should work", ->
    T1 = T.noConflict()
    expect(typeof T).toEqual('undefined')
    THIS.T = T1

