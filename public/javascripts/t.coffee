VERSION = "0.7.0"

create = ->
  T = (name, data...) ->
    template = T.templates[name]
    template.process(data...)

  T.VERSION   = VERSION
  T.create    = create
  T.templates = {}
  T.internal  = internal = {}

  internal.callbacks  = []
  internal.isArray    = (o) -> o instanceof Array
  internal.isObject   = (o) -> o isnt null and typeof o is "object" and (o not instanceof Array)
  internal.isTemplate = (o) -> o isnt null and typeof o is "object" and o.isTjsTemplate
  internal.isEmpty    = (o) ->
    return true unless o
    for own key of o
      return false
    return true

  internal.hasFunction = (o) ->
    return true if typeof o is 'function'
    return true if internal.isTemplate o

    if internal.isArray o
      for item in o
        return true if internal.hasFunction item

    else if internal.isObject o
      for own key, value of o
        return true if internal.hasFunction value

  internal.merge      = (o1, o2) ->
    return o1 unless o2
    return o2 unless o1

    for own key, value of o2
      o1[key] = value

    o1

  internal.Template = (@template, @name) ->
    @isTjsTemplate = true

  internal.Template.prototype.process = (data...) ->
    tags = internal.prepareOutput(@template, data...)
    tags = internal.normalize tags
    tags = internal.processAttributes tags
    new internal.TemplateOutput(this, tags)

  internal.Template.prototype.prepare = (includes) ->
    for own key, value of includes
      includes[key] = new internal.Template(value) unless internal.isTemplate value

    template = new internal.Template(@template, @name)
    template.process = (data...) ->
      try
        oldIncludes = internal.includes if internal.includes
        internal.includes = includes if includes

        internal.Template.prototype.process.call(this, data...)
      finally
        if oldIncludes
          internal.includes = oldIncludes
        else
          delete internal.includes

    template

  internal.TemplateOutput = (@template, @tags) ->

  internal.TemplateOutput.prototype.toString = ->
    internal.render @tags

  internal.TemplateOutput.prototype.render = (options) ->
    if options.inside
      $(options.inside).html(@toString())
    else if options.replace
      $(options.replace).replace(@toString())
    else if options.prepend
      $(options.prepend).prepend(@toString())
    else if options.append
      $(options.append).append(@toString())
    else if options.before
      $(options.before).before(@toString())
    else if options.after
      $(options.after).after(@toString())
    else if options.with
      options.with(@toString())

    internal.registerCallbacks()

  internal.RENDER_COMPLETE_CALLBACK = 'renderComplete'
  internal.FIRST_NO_PROCESS_PATTERN = /^<.*/
  internal.FIRST_FIELD_PATTERN      = /^([^#.]+)?(#([^.]+))?(.(.*))?$/

  # Parse first item and add parsed data to array
  internal.processFirst = (items) ->
    first = items[0]

    return items if internal.isArray first

    throw "Invalid first argument #{first}" unless typeof first is 'string'

    if first.match(internal.FIRST_NO_PROCESS_PATTERN)
      return items

    parts = first.split ' '
    if parts.length > 1
      i    = parts.length - 1
      rest = items.slice 1
      while i >= 0
        part = parts[i]
        rest.unshift part
        rest = [internal.processFirst(rest)]
        i--

      return rest[0]

    if matches = first.match(internal.FIRST_FIELD_PATTERN)
      tag     = matches[1] || 'div'
      id      = matches[3]
      classes = matches[5]
      if id or classes
        attrs = {}
        attrs.id    = id if id
        attrs.class = classes.replace(/\./g, ' ') if classes
        items.splice 0, 1, tag, attrs

    items

  # Normalize children recursively
  internal.normalize = (items) ->
    return items unless internal.isArray items

    for i in [items.length - 1..0]
      item = internal.normalize items[i]
      if internal.isArray item
        first = item[0]
        if first is ''
          item.shift()
          items.splice i, 1, item...
        else if internal.isArray first
          items.splice i, 1, item...
      else if item instanceof internal.TemplateOutput
        items[i] = item.tags
      else if typeof item is 'undefined' or item is null or item is ''
        #items.splice i, 1
      else
        items[i] = item

    items

  internal.parseStyles = (str) ->
    styles = {}
    for part in str.split(';')
      [name, value] = part.split(':')
      if name and value
        styles[name.trim()] = value.trim()
    styles

  internal.processStyles = (attrs) ->
    style = attrs.style

    if typeof style is 'string'
      attrs.style = internal.parseStyles(style)
    else if internal.isObject style and not internal.isEmpty style
      attrs.style = style

    attrs

  internal.processCssClasses = (attrs, newAttrs) ->
    if attrs.class
      if newAttrs.class
        newAttrs.class = attrs.class + ' ' + newAttrs.class
      else
        newAttrs.class = attrs.class

    newAttrs

  # Combine attributes into one hash and move to second position of array
  internal.processAttributes = (items) ->
    if internal.isArray items
      return items if items.length is 0

      attrs = {}
      items = internal.processFirst items
      for item in items
        if internal.isArray item
          internal.processAttributes item
        else if internal.isObject item
          internal.processStyles item
          styles = attrs.style
          newStyles = item.style

          # Set item.class to combined css classes, merge will overwrite attrs.class with it
          internal.processCssClasses(attrs, item)

          attrs = internal.merge(attrs, item)

          styles = internal.merge(styles, newStyles)
          attrs.style = styles unless internal.isEmpty styles

      for i in [items.length - 1..0]
        items.splice i, 1 if internal.isObject items[i]

      items.splice 1, 0, attrs unless internal.isEmpty attrs
    items

  internal.prepareOutput = (template, data...) ->
    if typeof template is 'function'
      internal.prepareOutput(template(data...), data...)
    else if internal.isTemplate template
      template.process(data...)
    else
      template

  internal.registerCallbacks = (config) ->
    while internal.callbacks.length > 0
      [cssClass, myCallbacks] = internal.callbacks.shift()

      for element in document.querySelectorAll('.' + cssClass)
        # Remove class from DOM
        if element.getAttribute('class') is cssClass
          element.removeAttribute('class')
        else
          element.setAttribute('class', element.getAttribute('class').replace(cssClass, ''))

        for own name, callback of myCallbacks
          if name is internal.RENDER_COMPLETE_CALLBACK
            callback(element)
          else
            $(element).on(name, callback)

  internal.getRandomCssClass = ->
    String(Math.random()).replace('0.', 'cls')

  internal.processCallbacks = (attributes) ->
    hasCallbacks = false
    myCallbacks  = {}

    for own key, value of attributes
      if typeof value is 'function'
        hasCallbacks     = true
        myCallbacks[key] = value
        delete attributes[key]

    if hasCallbacks
      cssClass = internal.getRandomCssClass()
      internal.callbacks.push([cssClass, myCallbacks])
      if attributes.class
        attributes.class += ' ' + cssClass
      else
        attributes.class = cssClass

  internal.renderAttributes = (attributes) ->
    result = ""

    internal.processCallbacks(attributes)

    for own key, value of attributes
      if key is "style"
        styles = attributes.style
        if internal.isObject styles
          s = ""
          for own name, style of styles
            if typeof style is 'number'
              style += 'px'
            s += name + ":" + style + ";"
          result += " style=\"" + s + "\""
        else
          result += " style=\"" + styles + "\""
      else
        result += " " + key + "=\"" + value + "\""

    result

  internal.renderRest = (input) ->
    (internal.render(item) for item in input).join('')

  internal.render = (input) ->
    return '' if typeof input is 'undefined' or input is null
    return '' + input unless internal.isArray input
    return '' if input.length is 0

    first = input.shift()

    # TODO: [['div'], ...]
    if internal.isArray first
      return internal.render(first) + (internal.render(item) for item in input).join('')

    return internal.renderRest input if first is ""
    if input.length is 0
      if first is 'script'
        return "<#{first}></#{first}>"
      else
        return "<" + first + "/>"

    result = "<" + first

    second = input.shift()
    if internal.isObject second
      result += internal.renderAttributes second

      if input.length is 0
        if first is 'script'
          result += "></#{first}>"
        else
          result += "/>"
        return result
      else
        result += ">"
    else
      result += ">"
      result += internal.render second
      if input.length is 0
        result += "</" + first + ">"
        return result

    if input.length > 0
      result += internal.renderRest input
      result += "</" + first + ">"

    result

  T.get  = (name) -> T.templates[name]

  T.each = (name, array, args...) ->
    T.process ->
      for item in array
        T(name, item, args...)

  T.each_with_index = (name, array, args...) ->
    T.process ->
      for item, i in array
        T(name, item, i, args...)

  T.each_pair = (name, hash, args...) ->
    T.process ->
      for own key, value of hash
        T(name, key, value, args...)

  T.process = (template, data...) ->
    new internal.Template(template).process data...

  T.include = (name, data...) ->
    internal.includes?[name].process(data...)

  T.define = T.def = (name, template)->
    T.templates[name] = new internal.Template(template, name)

  T.redefine = T.redef = (name, template) ->
    oldTemplate = T.templates[name]
    newTemplate = new internal.Template(template)
    wrapper = (data...) ->
      try
        backup = internal.original if internal.original
        internal.original = oldTemplate
        newTemplate.process(data...).tags
      finally
        if backup
          internal.original = backup
        else
          delete internal.original

    T.templates[name] = new internal.Template(wrapper, name)

  T.wrapped = (data...) ->
    internal.original.process(data...)

  T.escape  = (str) ->
    return str if not str
    str
     .replace(/&/g, "&amp;" )
     .replace(/</g, "&lt;"  )
     .replace(/>/g, "&gt;"  )
     .replace(/"/g, "&quot;")
     .replace(/'/g, "&#039;")

  T.unescape = (str) ->
    return str if not str
    str
     .replace(/&amp;/g , '&')
     .replace(/&lt;/g  , '<')
     .replace(/&gt;/g  , '>')
     .replace(/&quot;/g, '"')
     .replace(/&#039;/g, "'")

  # noConflict support
  internal.thisRef = this
  T.noConflict     = ->
    if T.oldT
      internal.thisRef.T = T.oldT
    else
      delete internal.thisRef.T
    T

  if this.T then T.oldT = this.T

  T

T = create()

# For browser
this.T = T

# Node.js exports
module?.exports = T

