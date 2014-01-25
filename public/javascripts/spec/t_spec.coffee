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

  it "should merge child array", ->
    input  = ['div', [class: 'test']]
    result = ['div', class: 'test']
    expect(T.internal.normalize(input)).toEqual(result)

  it "should normalize array if first item is an array", ->
    input  = ['div', [['div'], 'text']]
    result = ['div', ['div'], 'text']
    expect(T.internal.normalize(input)).toEqual(result)

  it "should normalize empty array", ->
    input  = ['div', [[], 'text']]
    result = ['div', 'text']
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

  it "should convert _ in style name to -", ->
    input  = {style: 'a_b:a-value;b:b-value;'}
    result = {style: {'a-b': 'a-value', b: 'b-value'}}
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

describe "T.internal.renderTags", ->
  it "should work", ->
    input  = ['div', 'text']
    result = T.internal.renderTags(input)
    expect(result.tagName).toEqual('DIV')
    expect(result.textContent).toEqual('text')

  it "should work with attributes", ->
    input  = ['div', {name: 'value'}]
    result = T.internal.renderTags(input)
    expect(result.tagName).toEqual('DIV')
    expect(result.getAttribute('name')).toEqual('value')

  it "should work with styles", ->
    input  = ['div', style: top: '3px']
    result = T.internal.renderTags(input)
    expect(result.tagName).toEqual('DIV')
    expect(result.getAttribute('style')).toEqual('top:3px;')

  it "should work with child tags", ->
    input  = ['div', ['span', 'text']]
    result = T.internal.renderTags(input)
    expect(result.tagName).toEqual('DIV')
    child = result.children[0]
    expect(child.tagName).toEqual('SPAN')
    expect(child.textContent).toEqual('text')

  it "should register event handlers", ->
    callback = jasmine.createSpy()
    input  = ['div', click: callback, 'text']
    result = T.internal.renderTags(input)
    $(result).click()
    expect(callback).toHaveBeenCalled()

  it "should invoke afterRender callback", ->
    elem = null
    afterRenderCalled = false
    input  = ['div', afterRender: (el) ->
      elem = el
      afterRenderCalled = true
    ]
    result = T.internal.renderTags(input)
    expect(elem).toBe(result)
    expect(afterRenderCalled).toBe(true)

  it "should invoke all afterRender callbacks", ->
    afterRenderCalled = 0
    input  = ['div',
      afterRender: [
        (el) -> afterRenderCalled += 1
        (el) -> afterRenderCalled += 1
      ]
    ]
    result = T.internal.renderTags(input)
    expect(afterRenderCalled).toBe(2)

  it "should work with child tags", ->
    input  = [['div', 'a'], ['span', 'b']]
    result = T.internal.renderTags(input)
    expect(result.childNodes[0].tagName).toEqual('DIV')
    expect(result.childNodes[0].textContent).toEqual('a')
    expect(result.childNodes[1].tagName).toEqual('SPAN')
    expect(result.childNodes[1].textContent).toEqual('b')

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

  it "should work with nested templates", ->
    child  = -> ['div', 'child']
    parent = -> ['div', 'parent', T(child)]
    result = ['div', 'parent', ['div', 'child']]
    expect(T(parent).tags).toEqual(result)

  it "should work with nested bare templates", ->
    grandChild  = -> ['div', 'grand child']
    child  = -> T(grandChild)
    parent = -> ['div', 'parent', T(child)]
    result = ['div', 'parent', ['div', 'grand child']]
    expect(T(parent).tags).toEqual(result)

  it "should invoke afterProcess callback", ->
    input  = ['div',
      afterProcess: (data) ->
        data.push 'value'
    ]
    result = T.process(input)
    expect(result.tags).toEqual(['div', 'value'])

  it "should invoke all afterProcess callbacks", ->
    input  = ['div',
      afterProcess: (data) -> data.push 'value1'
    , afterProcess: (data) -> data.push 'value2'
    ]
    result = T.process(input)
    expect(result.tags).toEqual(['div', 'value1', 'value2'])

describe "T.escape", ->
  it "should work", ->
    expect(T.escape('<>&<>&')).toEqual('&lt;&gt;&amp;&lt;&gt;&amp;')

describe "T.unescape", ->
  it "should work", ->
    expect(T.unescape('&lt;&gt;&amp;&lt;&gt;&amp;')).toEqual('<>&<>&')

describe "T()", ->
  it "should work", ->
    template = (data) -> ["div", data.name]
    data = name: 'John Doe'
    expect(T(template, data).tags).toEqual(['div', 'John Doe'])

  it "with multiple arguments should work", ->
    template = (arg1, arg2, arg3) -> ["div", arg1, arg2, arg3]
    result = ['div', '1', '2', '3']
    expect(T(template, '1', '2', '3').tags).toEqual(result)

  it "toString should work", ->
    template = (arg1, arg2, arg3) -> ["div", arg1, arg2, arg3]
    result = '<div>123</div>'
    expect(T(template, '1', '2', '3').toString()).toEqual(result)

  it "toString should not include generated class name if ignoreCallbacks is true", ->
    template = (arg) ->
      [ "div"
        click: ->
        arg
      ]
    result = '<div>value</div>'
    expect(T(template, 'value').toString(ignoreCallbacks: true)).toEqual(result)

  it "include template as partial should work", ->
    partial  = (data) -> ["div", data.name]
    template = (data) -> ["div", T(partial, data.account)]
    data   = account: name: 'John Doe'
    result = ['div', ['div', 'John Doe']]
    expect(T(template, data).tags).toEqual(result)

  it "complex template should work", ->
    profileTemplate = (data) -> ['div', data.username]
    accountTemplate = (data) -> ['div', data.name, T(profileTemplate, data.profile)]
    template = (data) -> ['div', T(accountTemplate, data.account)]
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
    expect(T(template, data).tags).toEqual(result)

describe "T.each", ->
  it "should work with array", ->
    template = (item, arg) -> ['div', item, arg]
    result = [
      ['div', 'a', 'arg']
      ['div', 'b', 'arg']
    ]
    expect(T(T.each(['a', 'b'], 'arg', template)).tags).toEqual(result)

  it "should work with hash", ->
    template = (key, value, arg) -> ['div', key, value, arg]
    result = [
      ['div', 'a', 'aa', 'arg']
      ['div', 'b', 'bb', 'arg']
    ]
    expect(T(T.each({a: 'aa', b: 'bb'}, 'arg', template)).tags).toEqual(result)

describe "T.each2", ->
  it "index should be passed in", ->
    template = (index, item, arg) -> ['div', index, item, arg]
    result = [
      ['div', 0, 'a', 'arg']
      ['div', 1, 'b', 'arg']
    ]
    expect(T(T.each2(['a', 'b'], 'arg', template)).tags).toEqual(result)

describe "prepare/include", ->
  it "should work", ->
    template = T.template (data) -> ['div', T.include('title', data)]
    partial  = T.template (data) -> ['div', data.name]
    expect(template.prepare(title: partial).process(name: 'John Doe').tags).toEqual(['div', ['div', 'John Doe']])

  it "T.prepare should work", ->
    layout   = (data) -> ['div', T.include('title', data)]
    partial  = (data) -> ['div', data.name]
    template = T.prepare(layout, title: partial)
    expect(template.process(name: 'John Doe').tags).toEqual(['div', ['div', 'John Doe']])

  it "layout can be reused", ->
    layout = T.template -> ['div', T.include('body')]
    template1 = layout.prepare(body: 'Body1')
    template2 = layout.prepare(body: 'Body2')
    expect(template1.process().tags).toEqual(['div', 'Body1'])
    expect(template2.process().tags).toEqual(['div', 'Body2'])

  it "nested include/prepare should work", ->
    template1 = T.template -> ['div', T.include('title')]
    template2 = T.template -> ['div', template1.prepare(title: 'Title').process(), T.include('body')]
    result = ['div', ['div', 'Title'], 'Body']
    expect(template2.prepare(body: 'Body').process().tags).toEqual(result)

describe "T.noConflict", ->
  it "should work", ->
    T1 = T.noConflict()
    expect(typeof T).toEqual('undefined')
    THIS.T = T1

