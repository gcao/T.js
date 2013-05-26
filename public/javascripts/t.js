// Generated by CoffeeScript 1.4.0
(function() {
  var FIRST_FIELD_PATTERN, FIRST_NO_PROCESS_PATTERN, T, Template, hasFunction, isArray, isEmpty, isObject, merge, normalize, parseStyles, prepareOutput, processAttributes, processCssClasses, processFirst, processStyles, render, renderAttributes, renderRest,
    __hasProp = {}.hasOwnProperty,
    __slice = [].slice;

  isArray = function(o) {
    return o instanceof Array;
  };

  isObject = function(o) {
    return o !== null && typeof o === "object" && (!(o instanceof Array));
  };

  isEmpty = function(o) {
    var key;
    if (!o) {
      return true;
    }
    for (key in o) {
      if (!__hasProp.call(o, key)) continue;
      return false;
    }
    return true;
  };

  hasFunction = function(o) {
    var item, key, value, _i, _len;
    if (typeof o === 'function') {
      return true;
    }
    if (isArray(o)) {
      for (_i = 0, _len = o.length; _i < _len; _i++) {
        item = o[_i];
        if (hasFunction(item)) {
          return true;
        }
      }
    } else if (isObject(o)) {
      if (o.isTjsTemplate) {
        return true;
      }
      for (key in o) {
        if (!__hasProp.call(o, key)) continue;
        value = o[key];
        if (hasFunction(value)) {
          return true;
        }
      }
    }
  };

  merge = function(o1, o2) {
    var key, value;
    if (!o2) {
      return o1;
    }
    if (!o1) {
      return o2;
    }
    for (key in o2) {
      if (!__hasProp.call(o2, key)) continue;
      value = o2[key];
      o1[key] = value;
    }
    return o1;
  };

  FIRST_NO_PROCESS_PATTERN = /^<.*/;

  FIRST_FIELD_PATTERN = /^([^#.]+)?(#([^.]+))?(.(.*))?$/;

  processFirst = function(items) {
    var attrs, classes, first, i, id, matches, part, parts, rest, tag;
    first = items[0];
    if (isArray(first)) {
      return items;
    }
    if (typeof first !== 'string') {
      throw "Invalid first argument " + first;
    }
    if (first.match(FIRST_NO_PROCESS_PATTERN)) {
      return items;
    }
    parts = first.split(' ');
    if (parts.length > 1) {
      i = parts.length - 1;
      rest = items.slice(1);
      while (i >= 0) {
        part = parts[i];
        rest.unshift(part);
        rest = [processFirst(rest)];
        i--;
      }
      return rest[0];
    }
    if (matches = first.match(FIRST_FIELD_PATTERN)) {
      tag = matches[1];
      id = matches[3];
      classes = matches[5];
      if (id || classes) {
        attrs = {};
        if (id) {
          attrs.id = id;
        }
        if (classes) {
          attrs["class"] = classes.replace('.', ' ');
        }
        items.splice(0, 1, tag, attrs);
      }
    }
    return items;
  };

  normalize = function(items) {
    var first, i, item, _i, _ref;
    if (!isArray(items)) {
      return items;
    }
    for (i = _i = _ref = items.length - 1; _ref <= 0 ? _i <= 0 : _i >= 0; i = _ref <= 0 ? ++_i : --_i) {
      item = normalize(items[i]);
      if (isArray(item)) {
        first = item[0];
        if (first === '') {
          item.shift();
          items.splice.apply(items, [i, 1].concat(__slice.call(item)));
        } else if (isArray(first)) {
          items.splice.apply(items, [i, 1].concat(__slice.call(item)));
        }
      } else if (typeof item === 'undefined' || item === null || item === '') {

      } else {
        items[i] = item;
      }
    }
    return items;
  };

  parseStyles = function(str) {
    var name, part, styles, value, _i, _len, _ref, _ref1;
    styles = {};
    _ref = str.split(';');
    for (_i = 0, _len = _ref.length; _i < _len; _i++) {
      part = _ref[_i];
      _ref1 = part.split(':'), name = _ref1[0], value = _ref1[1];
      if (name && value) {
        styles[name.trim()] = value.trim();
      }
    }
    return styles;
  };

  processStyles = function(attrs) {
    var newStyles, style, styles;
    newStyles = {};
    style = attrs.style;
    if (typeof style === 'string') {
      newStyles = merge(newStyles, parseStyles(style));
    }
    styles = attrs.styles;
    if (typeof styles === 'string') {
      newStyles = merge(newStyles, parseStyles(styles));
    }
    if (isObject(style)) {
      newStyles = merge(newStyles, style);
    }
    if (isObject(styles)) {
      newStyles = merge(newStyles, styles);
    }
    delete attrs.styles;
    if (!isEmpty(newStyles)) {
      attrs.style = newStyles;
    }
    return attrs;
  };

  processCssClasses = function(attrs, newAttrs) {
    if (attrs["class"]) {
      if (newAttrs["class"]) {
        newAttrs["class"] = attrs["class"] + ' ' + newAttrs["class"];
      } else {
        newAttrs["class"] = attrs["class"];
      }
    }
    return newAttrs;
  };

  processAttributes = function(items) {
    var attrs, i, item, newStyles, styles, _i, _j, _len, _ref;
    if (isArray(items)) {
      attrs = {};
      items = processFirst(items);
      for (_i = 0, _len = items.length; _i < _len; _i++) {
        item = items[_i];
        if (isArray(item)) {
          processAttributes(item);
        } else if (isObject(item)) {
          processStyles(item);
          styles = attrs.style;
          newStyles = item.style;
          processCssClasses(attrs, item);
          attrs = merge(attrs, item);
          styles = merge(styles, newStyles);
          if (!isEmpty(styles)) {
            attrs.style = styles;
          }
        }
      }
      for (i = _j = _ref = items.length - 1; _ref <= 0 ? _j <= 0 : _j >= 0; i = _ref <= 0 ? ++_j : --_j) {
        if (isObject(items[i])) {
          items.splice(i, 1);
        }
      }
      if (!isEmpty(attrs)) {
        items.splice(1, 0, attrs);
      }
    }
    return items;
  };

  prepareOutput = function(template, data) {
    var item, key, output, value, _i, _len, _results;
    if (typeof template === 'function') {
      return prepareOutput(template(data), data);
    } else if (isArray(template)) {
      if (hasFunction(template)) {
        _results = [];
        for (_i = 0, _len = template.length; _i < _len; _i++) {
          item = template[_i];
          _results.push(prepareOutput(item, data));
        }
        return _results;
      } else {
        return template;
      }
    } else if (isObject(template)) {
      if (template.isTjsTemplate) {
        return prepareOutput(template.process(data), data);
      } else if (hasFunction(template)) {
        output = {};
        for (key in template) {
          value = template[key];
          output[key] = prepareOutput(value, data);
        }
        return output;
      } else {
        return template;
      }
    } else {
      return template;
    }
  };

  renderAttributes = function(attributes) {
    var key, name, result, s, style, styles, value;
    result = "";
    for (key in attributes) {
      if (!__hasProp.call(attributes, key)) continue;
      value = attributes[key];
      if (key === "style") {
        styles = attributes.style;
        if (isObject(styles)) {
          s = "";
          for (name in styles) {
            if (!__hasProp.call(styles, name)) continue;
            style = styles[name];
            s += name + ":" + style + ";";
          }
          result += " style=\"" + s + "\"";
        } else {
          result += " style=\"" + styles + "\"";
        }
      } else {
        result += " " + key + "=\"" + value + "\"";
      }
    }
    return result;
  };

  renderRest = function(input) {
    var item;
    return ((function() {
      var _i, _len, _results;
      _results = [];
      for (_i = 0, _len = input.length; _i < _len; _i++) {
        item = input[_i];
        _results.push(render(item));
      }
      return _results;
    })()).join('');
  };

  render = function(input) {
    var first, result, second;
    if (typeof input === 'undefined' || input === null) {
      return '';
    }
    if (!isArray(input)) {
      return '' + input;
    }
    if (input.length === 0) {
      return '';
    }
    first = input.shift();
    if (first === "") {
      return renderRest(input);
    }
    if (input.length === 0) {
      if (first === 'script') {
        return "<" + first + "></" + first + ">";
      } else {
        return "<" + first + "/>";
      }
    }
    result = "<" + first;
    second = input.shift();
    if (isObject(second)) {
      result += renderAttributes(second);
      if (input.length === 0) {
        if (first === 'script') {
          result += "></" + first + ">";
        } else {
          result += "/>";
        }
        return result;
      } else {
        result += ">";
      }
    } else {
      result += ">";
      result += render(second);
      if (input.length === 0) {
        result += "</" + first + ">";
        return result;
      }
    }
    if (input.length > 0) {
      result += renderRest(input);
      result += "</" + first + ">";
    }
    return result;
  };

  Template = function(template) {
    this.template = template;
    return this.isTjsTemplate = true;
  };

  Template.prototype.map = function(mapper) {
    this.mapper = mapper;
    return this;
  };

  Template.prototype.process = function(data) {
    var output;
    if (this.mapper) {
      data = this.mapper(data);
    }
    output = prepareOutput(this.template, data);
    output = normalize(output);
    return processAttributes(output);
  };

  Template.prototype.render = function(data) {
    var output;
    output = this.process(data);
    return render(output);
  };

  Template.prototype.prepare = function(extras) {
    this.extras = extras;
    this.process = function(data) {
      var oldDefaultParam, oldExtras;
      try {
        if (T.defaultParam) {
          oldDefaultParam = T.defaultParam;
        }
        delete T.defaultParam;
        if (T.extras) {
          oldExtras = T.extras;
        }
        if (extras) {
          T.extras = extras;
        }
        return Template.prototype.process.call(this, data);
      } finally {
        if (oldDefaultParam) {
          T.defaultParam = oldDefaultParam;
        } else {
          delete T.defaultParam;
        }
        if (oldExtras) {
          T.extras = oldExtras;
        } else {
          delete T.extras;
        }
      }
    };
    return this;
  };

  Template.prototype.prepare2 = function(defaultParam, extras) {
    this.extras = extras;
    this.process = function(data) {
      var oldDefaultParam, oldExtras;
      try {
        if (T.defaultParam) {
          oldDefaultParam = T.defaultParam;
        }
        if (defaultParam) {
          T.defaultParam = defaultParam;
        }
        if (T.extras) {
          oldExtras = T.extras;
        }
        if (extras) {
          T.extras = extras;
        }
        return Template.prototype.process.call(this, data);
      } finally {
        if (oldDefaultParam) {
          T.defaultParam = oldDefaultParam;
        } else {
          delete T.defaultParam;
        }
        if (oldExtras) {
          T.extras = oldExtras;
        } else {
          delete T.extras;
        }
      }
    };
    return this;
  };

  T = function(template) {
    if (typeof template === 'object' && template.isTjsTemplate) {
      return template;
    } else {
      return new Template(template);
    }
  };

  T.process = function(template, data) {
    return T(template).process(data);
  };

  T.render = function(template, data) {
    return T(template).render(data);
  };

  T.get = function(name, defaultValue) {
    if (typeof defaultValue === 'undefined') {
      defaultValue = null;
    }
    return function(data) {
      var part, parts, _i, _len;
      if (!data) {
        return defaultValue;
      }
      parts = name.split('.');
      for (_i = 0, _len = parts.length; _i < _len; _i++) {
        part = parts[_i];
        data = data[part];
        if (typeof data === 'undefined' || data === null) {
          return defaultValue;
        }
      }
      if (typeof data === 'undefined' || data === null) {
        return defaultValue;
      } else {
        return data;
      }
    };
  };

  T.escape = function(str) {
    return str.replace(/&/g, "&amp;").replace(/</g, "&lt;").replace(/>/g, "&gt;").replace(/"/g, "&quot;").replace(/'/g, "&#039;");
  };

  T.unescape = function(str) {
    return str.replace(/&amp;/g, '&').replace(/&lt;/g, '<').replace(/&gt;/g, '>').replace(/&quot;/g, '"').replace(/&#039;/g, "'");
  };

  T.include = function(name, defaultValue) {
    return function() {
      var _ref;
      return ((_ref = T.extras) != null ? _ref[name] : void 0) || defaultValue;
    };
  };

  T.include2 = function(defaultValue) {
    return function() {
      return T.defaultParam || defaultValue;
    };
  };

  T.internal = {
    normalize: normalize,
    processFirst: processFirst,
    parseStyles: parseStyles,
    processStyles: processStyles,
    processAttributes: processAttributes,
    render: render,
    thisRef: this
  };

  T.noConflict = function() {
    if (T.oldT) {
      T.internal.thisRef.T = T.oldT;
    }
    return T;
  };

  if (this.T) {
    T.oldT = this.T;
  }

  this.T = T;

  if (typeof module !== "undefined" && module !== null) {
    module.exports = T;
  }

}).call(this);
