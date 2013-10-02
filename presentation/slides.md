
!SLIDE incremental title-and-content

# What is it?

The basic idea is to render a Javascript array as HTML tag. 

!SLIDE incremental

```javascript
['a', {src: '/test.html'}, 'This is a link']
```

* First item is the tag name, and id and css classes if present, e.g. 'div#id.class'
* Attributes are in hash
* Text contents are strings
* Child tags are in child arrays
* Texts and child tags are rendered sequentially

```html
<a src='/test.html'>This is a link</a>
```

!SLIDE incremental

With that in mind, you can use full Javascript's power to build up the array.

* Functions that return arrays:

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

