// Generated by CoffeeScript 1.4.0
(function() {

  describe("T.utils.processFirst", function() {
    it("should parse div#this.class1.class2", function() {
      var input, result;
      input = ['div#this.class1.class2', 'text'];
      result = [
        'div', {
          id: 'this',
          'class': 'class1 class2'
        }, 'text'
      ];
      return expect(T.utils.processFirst(input)).toEqual(result);
    });
    return it("should parse div#this", function() {
      var input, result;
      input = ['div#this', 'text'];
      result = [
        'div', {
          id: 'this'
        }, 'text'
      ];
      return expect(T.utils.processFirst(input)).toEqual(result);
    });
  });

  describe("T.utils.normalize", function() {
    it("should normalize array", function() {
      var input, result;
      input = ['div', ['', 'text']];
      result = ['div', 'text'];
      return expect(T.utils.normalize(input)).toEqual(result);
    });
    return it("should normalize array recursively", function() {
      var input, result;
      input = ['div', ['', 'text', ['', 'text2']]];
      result = ['div', 'text', 'text2'];
      return expect(T.utils.normalize(input)).toEqual(result);
    });
  });

  describe("T.utils.parseStyles", function() {
    return it("should parse styles", function() {
      var input, result;
      input = "a:a-value;b:b-value;";
      result = {
        a: 'a-value',
        b: 'b-value'
      };
      return expect(T.utils.parseStyles(input)).toEqual(result);
    });
  });

  describe("T.utils.processStyles", function() {
    return it("should work", function() {
      var input, result;
      input = {
        style: 'a:a-value;b:b-value;',
        styles: {
          c: 'c-value'
        }
      };
      result = {
        style: {
          a: 'a-value',
          b: 'b-value',
          c: 'c-value'
        }
      };
      return expect(T.utils.processStyles(input)).toEqual(result);
    });
  });

  describe("T.utils.processAttributes", function() {
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
      return expect(T.utils.processAttributes(input)).toEqual(result);
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
      return expect(T.utils.processAttributes(input)).toEqual(result);
    });
    it("should merge styles", function() {
      var input, result;
      input = [
        'div', {
          style: 'a:old-a;b:b-value;',
          styles: {
            c: 'c-value'
          }
        }, {
          style: 'a:new-a'
        }
      ];
      result = [
        'div', {
          style: {
            a: 'new-a',
            b: 'b-value',
            c: 'c-value'
          }
        }
      ];
      return expect(T.utils.processAttributes(input)).toEqual(result);
    });
    return it("should merge css classes", function() {
      var input, result;
      input = [
        'div', {
          'class': 'first second'
        }, {
          'class': 'third'
        }
      ];
      result = [
        'div', {
          'class': 'first second third'
        }
      ];
      return expect(T.utils.processAttributes(input)).toEqual(result);
    });
  });

  describe("T.process", function() {
    it("should create ready-to-be-rendered data structure from template and data", function() {
      var result, template;
      template = [
        'div#test', {
          'class': 'first second'
        }, {
          'class': 'third'
        }
      ];
      result = [
        'div', {
          id: 'test',
          'class': 'first second third'
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
    return it("should render template", function() {
      var result, template;
      template = [
        'div#test', {
          'class': 'first second'
        }, {
          'class': 'third'
        }
      ];
      result = '<div id="test" class="first second third"/>';
      return expect(T.render(template)).toEqual(result);
    });
  });

  describe("T.v", function() {
    it("should work", function() {
      var data, v;
      v = T.v('name');
      data = {
        name: 'John Doe'
      };
      return expect(v(data)).toEqual(data.name);
    });
    it("should work with nested attribute", function() {
      var data, v;
      v = T.v('account.name');
      data = {
        account: {
          name: 'John Doe'
        }
      };
      return expect(v(data)).toEqual(data.account.name);
    });
    return it("Should take default value", function() {
      var v;
      v = T.v('name', 'Default');
      return expect(v()).toEqual('Default');
    });
  });

  describe("T()", function() {
    it("T(T()) should return same Template object", function() {
      var t, t1;
      t = T("div", "text");
      t1 = T(t);
      return expect(t1).toEqual(t);
    });
    it("process should work", function() {
      var data, mapper, t, template;
      template = [
        "div", function(data) {
          return data.name;
        }
      ];
      mapper = function(data) {
        return data.account;
      };
      t = T(template).map(mapper);
      data = {
        account: {
          name: 'John Doe'
        }
      };
      return expect(t.process(data)).toEqual(['div', 'John Doe']);
    });
    it("process should work (old)", function() {
      var data, mapper, t, template;
      template = [
        "div", function(data) {
          return data.name;
        }
      ];
      mapper = function(data) {
        return data.account;
      };
      t = T(template).map(mapper);
      data = {
        account: {
          name: 'John Doe'
        }
      };
      return expect(t.process(data)).toEqual(['div', 'John Doe']);
    });
    it("include template as partial should work", function() {
      var partial, result, template;
      partial = [
        "div", function(data) {
          return data.name;
        }
      ];
      template = [
        "div", T(partial).map(function(data) {
          return data.account;
        })
      ];
      result = ['div', ['div', 'John Doe']];
      return expect(T(template).process({
        account: {
          name: 'John Doe'
        }
      })).toEqual(result);
    });
    return it("include template as partial should work", function() {
      var partial, result, template;
      partial = ["div", T.v('name')];
      template = [
        "div", T(partial).map(function(data) {
          return data.account;
        })
      ];
      result = '<div><div>John Doe</div></div>';
      return expect(T(template).render({
        account: {
          name: 'John Doe'
        }
      })).toEqual(result);
    });
  });

}).call(this);
