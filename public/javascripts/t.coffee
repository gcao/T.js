VERSION = "0.6.0"

isArray    = (o) -> o instanceof Array
isObject   = (o) -> o isnt null and typeof o is "object" and (o not instanceof Array)
isTemplate = (o) -> o isnt null and typeof o is "object" and o.isTjsTemplate

isEmpty    = (o) ->
  return true unless o
  for own key of o
    return false
  return true

hasFunction = (o) ->
  return true if typeof o is 'function'
  return true if isTemplate o

  if isArray o
    for item in o
      return true if hasFunction item

  else if isObject o
    for own key, value of o
      return true if hasFunction value

escape = (str) ->
  return str if not str
  str
   .replace(/&/g, "&amp;" )
   .replace(/</g, "&lt;"  )
   .replace(/>/g, "&gt;"  )
   .replace(/"/g, "&quot;")
   .replace(/'/g, "&#039;")

unescape = (str) ->
  return str if not str
  str
   .replace(/&amp;/g , '&')
   .replace(/&lt;/g  , '<')
   .replace(/&gt;/g  , '>')
   .replace(/&quot;/g, '"')
   .replace(/&#039;/g, "'")

merge      = (o1, o2) ->
  return o1 unless o2
  return o2 unless o1

  for own key, value of o2
    o1[key] = value

  o1

TemplateOutput = (@template, @tags) ->

TemplateOutput.prototype.toString = ->
  render @tags

TemplateOutput.prototype.render = (options) ->
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

  registerCallbacks()

RENDER_COMPLETE_CALLBACK = 'renderComplete'
callbacks = []

FIRST_NO_PROCESS_PATTERN = /^<.*/
FIRST_FIELD_PATTERN      = /^([^#.]+)?(#([^.]+))?(.(.*))?$/

# Parse first item and add parsed data to array
processFirst = (items) ->
  first = items[0]

  return items if isArray first

  throw "Invalid first argument #{first}" unless typeof first is 'string'

  if first.match(FIRST_NO_PROCESS_PATTERN)
    return items

  parts = first.split ' '
  if parts.length > 1
    i    = parts.length - 1
    rest = items.slice 1
    while i >= 0
      part = parts[i]
      rest.unshift part
      rest = [processFirst(rest)]
      i--

    return rest[0]

  if matches = first.match(FIRST_FIELD_PATTERN)
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
normalize = (items) ->
  return items unless isArray items

  for i in [items.length - 1..0]
    item = normalize items[i]
    if isArray item
      first = item[0]
      if first is ''
        item.shift()
        items.splice i, 1, item...
      else if isArray first
        items.splice i, 1, item...
    else if item instanceof TemplateOutput
      items[i] = item.tags
    else if typeof item is 'undefined' or item is null or item is ''
      #items.splice i, 1
    else
      items[i] = item

  items

parseStyles = (str) ->
  styles = {}
  for part in str.split(';')
    [name, value] = part.split(':')
    if name and value
      styles[name.trim()] = value.trim()
  styles

processStyles = (attrs) ->
  style = attrs.style

  if typeof style is 'string'
    attrs.style = parseStyles(style)
  else if isObject style and not isEmpty style
    attrs.style = style

  attrs

processCssClasses = (attrs, newAttrs) ->
  if attrs.class
    if newAttrs.class
      newAttrs.class = attrs.class + ' ' + newAttrs.class
    else
      newAttrs.class = attrs.class

  newAttrs

# Combine attributes into one hash and move to second position of array
processAttributes = (items) ->
  if isArray items
    return items if items.length is 0

    attrs = {}
    items = processFirst items
    for item in items
      if isArray item
        processAttributes item
      else if isObject item
        processStyles item
        styles = attrs.style
        newStyles = item.style

        # Set item.class to combined css classes, merge will overwrite attrs.class with it
        processCssClasses(attrs, item)

        attrs = merge(attrs, item)

        styles = merge(styles, newStyles)
        attrs.style = styles unless isEmpty styles

    for i in [items.length - 1..0]
      items.splice i, 1 if isObject items[i]

    items.splice 1, 0, attrs unless isEmpty attrs
  items

prepareOutput = (template, data...) ->
  if typeof template is 'function'
    prepareOutput(template(data...), data...)
  else if isTemplate template
    template.process(data...)
  else
    template

registerCallbacks = (config) ->
  while callbacks.length > 0
    [cssClass, myCallbacks] = callbacks.shift()

    for element in document.querySelectorAll('.' + cssClass)
      # Remove class from DOM
      if element.getAttribute('class') is cssClass
        element.removeAttribute('class')
      else
        element.setAttribute('class', element.getAttribute('class').replace(cssClass, ''))

      for own name, callback of myCallbacks
        if name is RENDER_COMPLETE_CALLBACK
          callback(element)
        else
          $(element).on(name, callback)

getRandomCssClass = ->
  String(Math.random()).replace('0.', 'cls')

processCallbacks = (attributes) ->
  hasCallbacks = false
  myCallbacks  = {}

  for own key, value of attributes
    if typeof value is 'function'
      hasCallbacks     = true
      myCallbacks[key] = value
      delete attributes[key]

  if hasCallbacks
    cssClass = getRandomCssClass()
    callbacks.push([cssClass, myCallbacks])
    if attributes.class
      attributes.class += ' ' + cssClass
    else
      attributes.class = cssClass

renderAttributes = (attributes) ->
  result = ""

  processCallbacks(attributes)

  for own key, value of attributes
    if key is "style"
      styles = attributes.style
      if isObject styles
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

renderRest = (input) ->
  (render(item) for item in input).join('')

render = (input) ->
  return '' if typeof input is 'undefined' or input is null
  return '' + input unless isArray input
  return '' if input.length is 0

  first = input.shift()

  # TODO: [['div'], ...]
  if isArray first
    return render(first) + (render(item) for item in input).join('')

  return renderRest input if first is ""
  if input.length is 0
    if first is 'script'
      return "<#{first}></#{first}>"
    else
      return "<" + first + "/>"

  result = "<" + first

  second = input.shift()
  if isObject second
    result += renderAttributes second

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
    result += render second
    if input.length is 0
      result += "</" + first + ">"
      return result

  if input.length > 0
    result += renderRest input
    result += "</" + first + ">"

  result

create = ->
  newT = (name, data...) ->
    template = newT.templates[name]
    template.process(data...)

  init(newT)
  newT

init = (T) ->
  T.create    = create
  T.templates = {}
  T.internal  = {}
  T.callbacks = callbacks

  Template = (@template, @name) ->
    @isTjsTemplate = true

  Template.prototype.process = (data...) ->
    tags = prepareOutput(@template, data...)
    tags = normalize tags
    tags = processAttributes tags
    new TemplateOutput(this, tags)

  Template.prototype.prepare = (includes) ->
    for own key, value of includes
      includes[key] = new Template(value) unless isTemplate value

    template = new Template(@template, @name)
    template.process = (data...) ->
      try
        oldIncludes = T.internal.includes if T.internal.includes
        T.internal.includes = includes if includes

        Template.prototype.process.call(this, data...) 
      finally
        if oldIncludes
          T.internal.includes = oldIncludes
        else
          delete T.internal.includes

    template

  T.get = (name) -> T.templates[name]

  T.process = (template, data...) ->
    new Template(template).process data...

  T.registerCallbacks = registerCallbacks

  T.include = (name, data...) ->
    T.internal.includes?[name].process(data...)

  T.define = T.def = (name, template)->
    T.templates[name] = new Template(template, name)

  T.redefine = T.redef = (name, template) ->
    oldTemplate = T.templates[name]
    newTemplate = new Template(template)
    wrapper = (data...) ->
      try
        backup = T.internal.original if T.original
        T.internal.original = oldTemplate
        newTemplate.process(data...).tags
      finally
        if backup
          T.internal.original = backup
        else
          delete T.internal.original

    T.templates[name] = new Template(wrapper, name)

  T.wrapped = (data...) ->
    T.internal.original.process(data...)

  T.escape   = escape
  T.unescape = unescape

  T.VERSION  = VERSION

T = create()

# Internal functions added for testing purpose
T.internal.normalize         = normalize
T.internal.processFirst      = processFirst
T.internal.parseStyles       = parseStyles
T.internal.processStyles     = processStyles
T.internal.processAttributes = processAttributes
T.internal.render            = render
T.internal.renderAttributes  = renderAttributes
T.internal.callbacks         = callbacks

# noConflict support
T.internal.thisRef           = this
T.noConflict = ->
  if T.oldT 
    T.internal.thisRef.T = T.oldT
  else
    delete T.internal.thisRef.T
  T

if this.T then T.oldT = this.T
this.T = T

# Node.js exports
module?.exports = T

