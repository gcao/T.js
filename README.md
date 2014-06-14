# T.js - a simple & powerful template engine

## DESCRIPTION

T.js is a template engine that uses simple Javascript data structure to
represent html/xml data.

### BASIC RULES

* A tag is represented by an array;
* First item is the tag name, and id and css classes if present, e.g.
  'div#id.class1.class2';
* Rest of the array contains the tag's attributes, text or child tags;
* Attributes are stored in hash, e.g. {"name": "username", "type": "text"};
* Text values are strings, e.g. "This is sample content";
* Child tags are in child arrays;
* Texts and child tags are rendered sequentially.

## USAGE

* Include T.js in HTML
```html
<script src="PATH_TO/t.js"></script>
```

* Define template
```javascript
var template = ["a.edit", {href: "/edit"}, "Edit"]
```

* Render
```javascript
var result = T(template).toString()
```

* Result is like
```html
<a class="edit" href="/edit">Edit</a>
```

## EXAMPLES

### EXAMPLE 1: A simple template that uses data
```javascript
var template = function(account){
  return ['div.account',
    ['div.header', 'Account Info'],
    ['div.label', 'Name'],
    ['div', account.name],
    ['div.label', 'Age'],
    ['div', account.age]
  ];
}
var account = {
  name: 'John Doe',
  age: 25
};
var result = T(template(account)).toString();
// result is like below (after formatted)
// <div class="account">
//   <div class="header">Account Info</div>
//   <div class="label">Name</div>
//   <div>John Doe</div>
//   <div class="label">Age</div>
//   <div>25</div>
// </div>
```

### [EXAMPLE 2: A simple TODO list](http://jsfiddle.net/gcao/gRzNP/)

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
open http://localhost:8000/spec_runner

* Convert between html and T:
bin/html2t spec/fixtures/test.html
bin/html2t spec/fixtures/test.html | bin/t2html

* Convert T to CoffeeScript (js2coffee has to be installed):
bin/html2t spec/fixtures/test.html | js2coffee

* Convert haml to html to T template to html:
bundle exec bin/haml2erb spec/fixtures/test.haml | HTML_FRAGMENT=true bin/html2t | bin/t2html

* Integrate with Jasmine Headless WebKit:
Config file is located at public/javascripts/spec/jasmine.yml
jasmine-headless-webkit -c -j public/javascripts/spec/jasmine.yml

## CREDITS

* I got the basic idea of T.js from [LM.JS](https://github.com/rudenoise/LM.JS)
but has implemented from scratch with several additional interesting features.

## COPYRIGHT

Copyright (c) 2013 Guoliang Cao. See LICENSE.txt for further details.

