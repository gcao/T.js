// Generated by CoffeeScript 1.4.0
(function() {
  var THIS;

  THIS = this;

  describe("T.internal.processFirst", function() {
    it("should parse div#this.class1.class2", function() {
      var input, result;
      input = ['div#this.class1.class2', 'text'];
      result = [
        'div', {
          id: 'this',
          'class': 'class1 class2'
        }, 'text'
      ];
      return expect(T.internal.processFirst(input)).toEqual(result);
    });
    it("should parse div#this", function() {
      var input, result;
      input = ['div#this', 'text'];
      result = [
        'div', {
          id: 'this'
        }, 'text'
      ];
      return expect(T.internal.processFirst(input)).toEqual(result);
    });
    it("should parse 'div#this div.child'", function() {
      var input, result;
      input = ['div#this div.child', 'text'];
      result = [
        'div', {
          id: 'this'
        }, [
          'div', {
            "class": 'child'
          }, 'text'
        ]
      ];
      return expect(T.internal.processFirst(input)).toEqual(result);
    });
    it("should return as is if first starts with '<'", function() {
      var input, result;
      input = ['<!DOCTYPE html>', '...'];
      result = input;
      return expect(T.internal.processFirst(input)).toEqual(result);
    });
    return it("should return as is if first is an array", function() {
      var input, result;
      input = [[], '...'];
      result = input;
      return expect(T.internal.processFirst(input)).toEqual(result);
    });
  });

  describe("T.internal.normalize", function() {
    it("should normalize array", function() {
      var input, result;
      input = ['div', ['', 'text']];
      result = ['div', 'text'];
      return expect(T.internal.normalize(input)).toEqual(result);
    });
    it("should normalize array if first item is an array", function() {
      var input, result;
      input = ['div', [['div'], 'text']];
      result = ['div', ['div'], 'text'];
      return expect(T.internal.normalize(input)).toEqual(result);
    });
    return it("should normalize array recursively", function() {
      var input, result;
      input = ['div', ['', 'text', ['', 'text2']]];
      result = ['div', 'text', 'text2'];
      return expect(T.internal.normalize(input)).toEqual(result);
    });
  });

  describe("T.internal.parseStyles", function() {
    return it("should parse styles", function() {
      var input, result;
      input = "a:a-value;b:b-value;";
      result = {
        a: 'a-value',
        b: 'b-value'
      };
      return expect(T.internal.parseStyles(input)).toEqual(result);
    });
  });

  describe("T.internal.processStyles", function() {
    return it("should work", function() {
      var input, result;
      input = {
        style: 'a:a-value;b:b-value;'
      };
      result = {
        style: {
          a: 'a-value',
          b: 'b-value'
        }
      };
      return expect(T.internal.processStyles(input)).toEqual(result);
    });
  });

  describe("T.internal.processAttributes", function() {
    it("should merge attributes", function() {
      var input, result;
      input = [
        'div', {
          a: 1
        }, {
          a: 11,
          b: 2
        }
      ];
      result = [
        'div', {
          a: 11,
          b: 2
        }
      ];
      return expect(T.internal.processAttributes(input)).toEqual(result);
    });
    it("should merge attributes and keep other items untouched", function() {
      var input, result;
      input = [
        'div', {
          a: 1
        }, 'first', {
          b: 2
        }, 'second'
      ];
      result = [
        'div', {
          a: 1,
          b: 2
        }, 'first', 'second'
      ];
      return expect(T.internal.processAttributes(input)).toEqual(result);
    });
    it("should merge styles", function() {
      var input, result;
      input = [
        'div', {
          style: 'a:old-a;b:b-value;'
        }, {
          style: 'a:new-a'
        }
      ];
      result = [
        'div', {
          style: {
            a: 'new-a',
            b: 'b-value'
          }
        }
      ];
      return expect(T.internal.processAttributes(input)).toEqual(result);
    });
    return it("should merge css classes", function() {
      var input, result;
      input = [
        'div', {
          "class": 'first second'
        }, {
          "class": 'third'
        }
      ];
      result = [
        'div', {
          "class": 'first second third'
        }
      ];
      return expect(T.internal.processAttributes(input)).toEqual(result);
    });
  });

  describe("T.process", function() {
    it("should create ready-to-be-rendered data structure from template and data", function() {
      var result, template;
      template = [
        'div#test', {
          "class": 'first second'
        }, {
          "class": 'third'
        }
      ];
      result = [
        'div', {
          id: 'test',
          "class": 'first second third'
        }
      ];
      return expect(T.process(template)).toEqual(result);
    });
    return it("can be called with different data", function() {
      var template;
      template = [
        'div', function(data) {
          return data;
        }
      ];
      expect(T.process(template, 'test')).toEqual(['div', 'test']);
      return expect(T.process(template, 'test1')).toEqual(['div', 'test1']);
    });
  });

  describe("T.render", function() {
    it("should work", function() {
      var result, template;
      template = ['div', 'a', 'b'];
      result = '<div>ab</div>';
      return expect(T.render(template)).toEqual(result);
    });
    it("should work", function() {
      var result, template;
      template = [['div', 'a'], ['div', 'b']];
      result = '<div>a</div><div>b</div>';
      return expect(T.render(template)).toEqual(result);
    });
    it("empty script should not self-close", function() {
      var result, template;
      template = ['script'];
      result = '<script></script>';
      return expect(T.render(template)).toEqual(result);
    });
    it("script should not self-close", function() {
      var result, template;
      template = [
        'script', {
          src: 'test.js'
        }
      ];
      result = '<script src="test.js"></script>';
      return expect(T.render(template)).toEqual(result);
    });
    return it("should render template", function() {
      var result, template;
      template = [
        'div#test', {
          "class": 'first second'
        }, {
          "class": 'third'
        }
      ];
      result = '<div id="test" class="first second third"/>';
      return expect(T.render(template)).toEqual(result);
    });
  });

  describe("T.def/use", function() {
    it("should work", function() {
      var result;
      T.def('template', function(data) {
        return ['div', data];
      });
      result = ['div', 'value'];
      return expect(T.use('template').process('value')).toEqual(result);
    });
    return it("redef should work", function() {
      var result;
      T.def('template', function(data) {
        return ['div', data];
      });
      T.redef('template', function(data) {
        return ['div.container', T.original.process(data)];
      });
      result = [
        "div", {
          "class": 'container'
        }, ['div', 'value']
      ];
      return expect(T.use('template').process('value')).toEqual(result);
    });
  });

  describe("T()", function() {
    it("process should work", function() {
      var data;
      T.def('template', function(data) {
        return ["div", data.name];
      });
      data = {
        name: 'John Doe'
      };
      return expect(T('template').process(data)).toEqual(['div', 'John Doe']);
    });
    it("T(template, data) should call process", function() {
      var data;
      T.def('template', function(data) {
        return ["div", data.name];
      });
      data = {
        name: 'John Doe'
      };
      return expect(T('template', data)).toEqual(['div', 'John Doe']);
    });
    it("include template as partial should work", function() {
      var data, result;
      T.def('partial', function(data) {
        return ["div", data.name];
      });
      T.def('template', function(data) {
        return ["div", T('partial', data.account)];
      });
      data = {
        account: {
          name: 'John Doe'
        }
      };
      result = ['div', ['div', 'John Doe']];
      return expect(T('template', data)).toEqual(result);
    });
    return it("complex template should work", function() {
      var data, result;
      T.def('profileTemplate', function(data) {
        return ['div', data.username];
      });
      T.def('accountTemplate', function(data) {
        return ['div', data.name, T('profileTemplate', data.profile)];
      });
      T.def('template', function(data) {
        return ['div', T('accountTemplate', data.account)];
      });
      result = ['div', ['div', 'John Doe', ['div', 'johndoe']]];
      data = {
        account: {
          name: 'John Doe',
          profile: {
            username: 'johndoe'
          }
        }
      };
      return expect(T('template', data)).toEqual(result);
    });
  });

  describe("T().prepare/T.include", function() {
    it("should work", function() {
      var partial;
      T.def('template', function(data) {
        return ['div', T.include('title', data)];
      });
      partial = T.def(function(data) {
        return ['div', data.name];
      });
      return expect(T('template').prepare({
        title: partial
      }).process({
        name: 'John Doe'
      })).toEqual(['div', ['div', 'John Doe']]);
    });
    it("prepare2 should work", function() {
      T.def('template', ['div', T.include2(), T.include('title')]);
      return expect(T('template').prepare2(T.def('first'), {
        title: T.def('Title')
      }).process()).toEqual(['div', 'first', 'Title']);
    });
    return it("nested include/prepare should work", function() {
      T.def('template', ['div', T.include('title')]);
      T.def('template2', [
        'div', T('template').prepare({
          title: T.def('Title')
        }), T.include('body')
      ]);
      return expect(T('template2').prepare({
        body: T.def('Body')
      }).process()).toEqual(['div', ['div', 'Title'], 'Body']);
    });
  });

  describe("T.noConflict", function() {
    return it("should work", function() {
      var T1;
      T1 = T.noConflict();
      expect(typeof T).toEqual('undefined');
      return THIS.T = T1;
    });
  });

}).call(this);
