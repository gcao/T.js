VERSION = "0.8.0"

T = (template, data...) ->
  if not internal.isTemplate template
    template = new internal.Template(template)
  template.process(data...)

T.VERSION  = VERSION
T.internal = internal = {}

internal.callbacks  = []
internal.isArray    = (o) -> o instanceof Array
internal.isObject   = (o) -> o isnt null and typeof o is "object" and (o not instanceof Array)
internal.isTemplate = (o) -> o instanceof internal.Template
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
    if ['afterProcess', 'afterRender'].indexOf(key) >= 0
      value1 = o1[key]
      if value1
        if internal.isArray value1
          value1.push value
        else
          o1[key] = [value1, value]
      else
        o1[key] = value
    else
      o1[key] = value

  o1

internal.Template = (@template) ->

internal.Template.prototype.process = (data...) ->
  tags = internal.prepareOutput(@template, data...)
  tags = internal.normalize tags
  tags = internal.processAttributes tags
  internal.handleAfterProcess tags
  new internal.TemplateOutput(this, tags)

internal.Template.prototype.prepare = (includes) ->
  for own key, value of includes
    includes[key] = new internal.Template(value) unless internal.isTemplate value

  template = new internal.Template(@template)
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

internal.TemplateOutput.prototype.toString = (options) ->
  internal.render @tags, options

internal.TemplateOutput.prototype.render = (options) ->
  if options.inside
    $(options.inside).html(@toString())
  else if options.replace
    $(options.replace).replaceWith(@toString())
  else if options.prependTo
    $(options.prependTo).prepend(@toString())
  else if options.appendTo
    $(options.appendTo).append(@toString())
  else if options.before
    $(options.before).before(@toString())
  else if options.after
    $(options.after).after(@toString())
  else if options.here
    document.write(@toString())
  else if options.handler
    options.handler(@toString())
  else
    return internal.renderTags @tags

  internal.registerCallbacks()

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
  if items is null or typeof items is 'undefined'
    return ''
  else if items instanceof internal.TemplateOutput
    return internal.normalize items.tags
  else if internal.isArray items
    if items.length is 0
      return ''
  else
    return items 

  for i in [items.length - 1..0]
    item = internal.normalize items[i]
    items[i] = item
    if internal.isArray item
      first = item[0]
      if first is ''
        items.splice i, 1, item...
      else if internal.isArray(first) or internal.isObject(first)
        items.splice i, 1, item...

  for i in [items.length - 1..1]
    item = items[i]
    if item is '' or typeof item is 'undefined' or item is null
      items.splice i, 1

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

  if attrs.style
    for own key, value of attrs.style
      if key.indexOf('_') >= 0
        delete attrs.style[key]
        attrs.style[key.replace(/_/g, '-')] = value

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
  else if template instanceof internal.TemplateOutput
    template.tags
  else
    template

internal.handleAfterProcess = (arr) ->
  if not internal.isArray arr then return
  for item in arr
    internal.handleAfterProcess item

  callbacks = arr[1]?.afterProcess
  if callbacks
    if typeof callbacks is 'function'
      callbacks(arr)
    else
      for callback in callbacks
        callback(arr)

    delete arr[1].afterProcess
    if internal.isEmpty(arr[1]) then arr.splice(1, 1)

internal.handleAfterRender = (callbacks, el) ->
  if not callbacks then return

  if typeof callbacks is 'function'
    callbacks(el)
  else
    for callback in callbacks
      callback(el)

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
        if name is 'afterRender'
          internal.handleAfterRender(callback, element)
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
    if value is null or typeof value is 'undefined' then continue

    if key is "temp"
    else if key is "style"
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

internal.renderRest = (input, options) ->
  (internal.render(item, options) for item in input).join('')

internal.render = (input, options) ->
  return '' if typeof input is 'undefined' or input is null
  return '' + input unless internal.isArray input
  return '' if input.length is 0

  first = input.shift()

  if internal.isArray first
    return internal.render(first, options) + (internal.render(item, options) for item in input).join('')

  return internal.renderRest(input, options) if first is ""
  if input.length is 0
    if first is 'script'
      return "<#{first}></#{first}>"
    else
      return "<" + first + "/>"

  result = "<" + first

  second = input.shift()
  if internal.isObject second
    attrs = second
    if options?.ignoreCallbacks
      attrs = {}
      for own key, value of second
        attrs[key] = value unless typeof value is 'function'

    result += internal.renderAttributes attrs

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
    result += internal.renderRest input, options
    result += "</" + first + ">"

  result

internal.renderTags = (tags) ->
  if internal.isArray tags[0]
    parent = document.createElement('div')

  internal.renderChildTags parent, tags

internal.renderChildTags = (parent, tags) ->
  if internal.isArray tags[0]
    for item in tags
      internal.renderChildTags parent, item
    return parent

  el = document.createElement(tags.shift())
  if parent then parent.appendChild el

  afterRender = null

  for part in tags
    if typeof part is 'string'
      el.appendChild document.createTextNode(part)
    else if internal.isObject part
      for own key, value of part
        if key is 'afterRender'
          afterRender = value
        else if typeof value is 'function'
          $(el).bind(key, value)
          # For some reason, below code does not work in Jasmine Headless mode
          #if el.addEventListener
          #  el.addEventListener key, value, false
          #else if el.attachEvent # Old IE support
          #  el.attachEvent "on#{key}", value
        else if key.toLowerCase() is 'style' and internal.isObject value
            s = ""
            for own k, v of value
              s += "#{k}:#{v};"
            value = s

          el.setAttribute(key, value)
    else if internal.isArray part
      internal.renderChildTags(el, part)

  internal.handleAfterRender(afterRender, el)

  el

T.if = (cond, trueValue, falseValue) ->
  if typeof cond is 'function'
    cond = cond()

  result = if cond then trueValue else falseValue
  if typeof result is 'function'
    result()
  else
    result

T.unless = T.ifNot = (cond, value) ->
  if typeof cond is 'function'
    cond = cond()

  if not cond
    if typeof value is 'function'
      value()
    else
      value

T.each = (o, args..., template) ->
  if internal.isArray o
    for item in o
      template(item, args...)
  else
    for own key, value of o
      template(key, value, args...)

T.each2 = (o, args..., template) ->
  for item, i in o
    template(i, item, args...)

T.process = (template, data...) ->
  if not internal.isTemplate template
    template = new internal.Template(template)
  template.process data...

T.prepare = (template, includes) ->
  if not internal.isTemplate template
    template = new internal.Template(template)
  template.prepare includes

T.include = (name, data...) ->
  internal.includes?[name]?.process(data...)

T.template = (template) -> new internal.Template(template)

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

# For browser
this.T = T

# Node.js exports
module?.exports = T

