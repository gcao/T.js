# T.js - a simple & powerful template engine

## DESCRIPTION

T.js is a template engine that uses simple Javascript data structure to 
represent html/xml data.

### BASIC RULES

* A tag is represented by an array;
* First item is the tag name, optionally it could contain id and css classes,
  e.g. 'div#id.class1.class2';
* Rest of the array contains the tag's attributes, text or child tags;
* Attributes are stored in hash, e.g. {"name": "username", "type": "text"};
* Text values are strings, e.g. "This is sample content";
* Child tags are in child arrays;
* Attributes can appear anywhere after tag name;
* Texts and child tags are rendered sequentially.

#### EXAMPLE 1

* INPUT
```javascript
var template = ["a.edit", {"href": "/edit"}, "Edit"]
```

* RUN
```javascript
T(template).render()
```

* RESULT
```html
<a class="edit" href="/edit">Edit</a>
```

### ADVANCED FEATURES

* Functions can be used everywhere, they'll be invoked and their results will
  be used to generate final output, e.g. 
  ```javascript
  ['div.now', function(){return new Date();}]
  ```

* A data argument can be passed on rendering the template, it will then be
  passed to functions inside the template, e.g.
  ```javascript
  var template = ['div.total', function(data){return data.total;}];
  T(template).render({total: 100});
  ```

* Layout, e.g.
  ```javascript
  var layout = ['div', ['div', 'Title'], T.include('body')]
  var body = ['div', 'Body']
  T(layout).prepare({'body': body}).render()
  ```

## DEVELOPMENT SETUP (MAC)

  $ git clone git://github.com/gcao/T.js.git  
  $ cd T.js

  $ brew install node  
  $ npm install coffee-script  

  $ gem install bundler  
  $ bundle  
  $ guard  

## NOTES

* Run with LiveReload support:  
thin -p 8000 start

* Run with no external dependency:  
cd public && python -m SimpleHTTPServer

* Open Demo Page:  
open http://localhost:8000

* Run Jasmine tests in browser:  
open http://localhost:8000/spec_runner.html

* Convert between html and T:  
bin/html2t spec/fixtures/test.html  
bin/html2t spec/fixtures/test.html | bin/t2html  
cat spec/fixtures/test.js | bin/t2html

* Convert T to CoffeeScript (js2coffee has to be installed):  
bin/html2t spec/fixtures/test.html | js2coffee

* Convert haml to html to T template to html:  
bundle exec bin/haml2erb spec/fixtures/test.haml | HTML_FRAGMENT=true bin/html2t | bin/t2html

* Integrate with Jasmine Headless WebKit:  
Config file is located at public/javascripts/spec/jasmine.yml  
jasmine-headless-webkit -c -j public/javascripts/spec/jasmine.yml

