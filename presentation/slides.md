
!SLIDE title-and-content

# What Is T.js?

A small JavaScript library that enables writing HTML template in JavaScript.

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
* Attributes are object properties
* Text contents are strings
* Child tags are child arrays
* Texts and child tags are rendered sequentially

!SLIDE incremental

# What Does It Imply?

We can use JavaScript's full power to build up the array

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
var template = function(arg1, arg2){
  return ['div', arg1, arg2];
}

// Process
T(template('First', 'Second'))

// Render: will replace body's content with the result
T(template('First', 'Second')).render({inside: 'body'});

T(template('First', 'Second')).toString(); // <div>FirstSecond</div>
```

!SLIDE incremental text-size-90

# T.js And CoffeeScript <br/>A Match Made In Heaven

## Templates written in CoffeeScript look beautiful!

```coffeescript
todo = (todos, index) ->
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
  todo = (todos, index) ->
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

# afterRender Callback

* Will be executed after tags are inserted into DOM
* Any element can have its own callback
* Like event handlers, afterRender can access both data and element

  ```coffeescript
  template = (name) ->
      [ "div"
        afterRender: (el) ->
          console.log(name + " is rendered.")
        name
      ]
  ```

!SLIDE title

# EXAMPLES

!SLIDE incremental text-size-90

# Look Ma, Two Way Data Binding

<div id='data-binding' style='margin-left: 105px; margin-top: -10px; margin-bottom: -10px; font-size: 18px;'/>

<script type="text/javascript">
var bind = function(el, obj, property) {
  var tagName = $(el).get(0).tagName;

  watch(obj, property, function() {
    if (tagName === 'INPUT') {
      $(el).val(obj[property]);
    } else if (tagName === 'SPAN') {
      $(el).text(obj[property]);
    }
  });
  if (tagName === 'INPUT') {
    return $(el).change(function() {
      obj[property] = $(this).val();
    });
  }
};

var template = function(data) {
  return [
    'div', {
      afterRender: function(el) {
        bind($(el).find('input'), data, 'name');
      }
    }, [
      "span", {
        afterRender: function(el) {
          bind(el, data, 'name');
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
}

var model = {
  name: 'John Doe'
};

T(template(model)).render({
  inside: '#data-binding'
});
</script>

* Data binding, especially two way data binding, is really hard!
* JavaScript frameworks are catching up in this area.
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

template = (data) ->
  [ 'div'
    afterRender: (el) -> bind($(el).find('input'), data, 'name')
    [ "span",
      afterRender: (el) -> bind(el, data, 'name')
      data.name
    ]
    [ "input"
      type: "text"
      value: data.name
    ]
  ]

model = name: 'John Doe'
T(template(model)).render inside: 'body'
```

!SLIDE

# TODO Example

http://jsfiddle.net/gcao/gRzNP/

!SLIDE title

# Q & A

!SLIDE title

# THANK YOU!
