
!SLIDE title-and-content

# What Is T.js?

A small Javascript library that enables writing HTML template in Javascript.

!SLIDE incremental text-size-80

# Core Idea

Map an array to a HTML tag

```javascript
['a.test', {src: '/test.html'}, 'This is a link']
```

```html
<a class="test" src="/test.html">This is a link</a>
```

* First item is the tag name, and id and css classes if present, e.g. 'div#id.class'
* Attributes are in hash
* Text contents are strings
* Child tags are in child arrays
* Texts and child tags are rendered sequentially

!SLIDE incremental

# What Does It Imply?

We can use full Javascript's power to build up the array

E.g. create functions that return arrays:

```javascript
var template = function(account){
    return ['div', account.name];
}
template({name: 'John Doe'});
```

```html
<div>John Doe</div>
```

!SLIDE

# T.js API

Define => Process => Render

```javascript
// Define
T.def('name', function(arg1, arg2){
  return ['div', arg1, arg2];
});

// Process
T('name', 'First', 'Second') <=> T('name').process('First', 'Second')

// Render: will replace body's content with the result
T('name', 'First', 'Second').render({inside: 'body'});

T('name') // The template object

T('name', 'First', 'Second').toString(); // <div>FirstSecond</div>
```

!SLIDE incremental text-size-90

# T.js And CoffeeScript <br/>A Match Made In Heaven

## Templates written in CoffeeScript look beautiful!

```coffeescript
T.def 'todo', (todos, index) ->
  [ "div.todo"
    style: padding: "3px"

    todos[index]
    "&nbsp;&nbsp;"
    [ "a"
      href: "javascript:void(0)"
      click: ->
        todos.splice(index, 1)
      "X"
    ]
  ]
```

!SLIDE incremental text-size-90

# Event Handlers

* Can embed event handler functions in template
* Event handlers can access both data and element

  ```coffeescript
  T.def 'todo', (todos, index) ->
      [ "div.todo"
        todos[index]
        [ "a"
          href: "javascript:void(0)"
          click: ->
            todos.splice(index, 1)
            console.log(todos)
          "X"
        ]
      ]
  ```

!SLIDE incremental text-size-90

# renderComplete Callback

* Will be executed after tags are inserted into DOM
* Any element can have its own callback
* Like event handlers, renderComplete can access both data and element

  ```coffeescript
  T.def 'name', (name) ->
      [ "div"
        renderComplete: (el) ->
          console.log(name + " is rendered.")
        name
      ]
  ```

!SLIDE incremental text-size-90

# Look Ma, Two Way Data Binding

<div id='data-binding' style='margin-left: 105px; margin-top: -10px; margin-bottom: -10px; font-size: 18px;'/>

<script type="text/javascript">
var bind;

bind = function(el, obj, properties, options) {
  var tagName;
  tagName = $(el).get(0).tagName;
  watch(obj, properties, function() {
    if (tagName === 'INPUT') {
      return $(el).val(obj[properties]);
    } else if (tagName === 'SPAN') {
      return $(el).text(obj[properties]);
    }
  });
  if (tagName === 'INPUT') {
    return $(el).change(function() {
      return obj[properties] = $(this).val();
    });
  }
};

T.def('main', function(data) {
  return [
    'div', {
      renderComplete: function(el) {
        return bind($(el).find('input'), data, 'name');
      }
    }, [
      "span", {
        renderComplete: function(el) {
          return bind(el, data, 'name');
        }
      }, data.name
    ], [
      "input", {
        type: "text",
        value: data.name
      }
    ], [
      "input", {
        type: "text",
        value: data.name
      }
    ]
  ];
});

window.data = {
  name: 'John Doe'
};

T('main', data).render({
  inside: '#data-binding'
});
</script>

* Data binding, especially two way data binding, is really hard!
* Javascript frameworks are catching up in this area.
* KnockoutJS is a very good data binding framework, its implementation is complex though.
* Using **T.js** and **Watch.js**, we could achieve two way data binding with little code.

!SLIDE text-size-80

```coffeescript
bind = (el, obj, properties, options) ->
  tagName = $(el).get(0).tagName
  watch obj, properties, ->
    if tagName is 'INPUT'
      $(el).val(obj[properties])
    else if tagName is 'SPAN'
      $(el).text(obj[properties])
  if tagName is 'INPUT'
    $(el).change -> obj[properties] = $(this).val()

# Template
T.def 'main', (data) ->
  [ 'div'
    renderComplete: (el) -> bind($(el).find('input'), data, 'name')
    [ "span",
      renderComplete: (el) -> bind(el, data, 'name')
      data.name
    ]
    [ "input"
      type: "text"
      value: data.name
    ]
  ]

# Model
window.data = name: 'John Doe'
T('main', data).render inside: 'body'
```

!SLIDE

# TODO Example

http://jsfiddle.net/gcao/gRzNP/

!SLIDE title

# Q & A

!SLIDE title

# THANK YOU!
