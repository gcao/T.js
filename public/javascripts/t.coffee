isArray    = (o) -> o instanceof Array
isObject   = (o) -> o isnt null and typeof o is "object" and (o not instanceof Array)

isEmpty    = (o) ->
  return true unless o
  for own key of o
    return false
  return true

hasFunction = (o) ->
  return true if typeof o is 'function'

  if isArray o
    for item in o
      return true if hasFunction item

  else if isObject o
    return true if o.isTemplate

    for own key, value of o
      return true if hasFunction value

merge      = (o1, o2) ->
  return o1 unless o2
  return o2 unless o1

  for own key, value of o2
    o1[key] = value

  o1

#FirstFieldPattern = /^([^#.]+)?([#\.][^\s]+)*$/
FirstFieldPattern = /^([^#.]+)?(#([^.]+))?(.(.*))?$/

# Parse first item and add parsed data to array
processFirst = (items) ->
  first = items[0]

  throw "Invalid first argument #{first}" unless typeof first is 'string'

  if matches = first.match(FirstFieldPattern)
    tag     = matches[1]
    id      = matches[3]
    classes = matches[5]
    if id or classes
      attrs = {}
      attrs.id    = id if id
      attrs.class = classes.replace('.', ' ') if classes
      items.splice 0, 1, tag, attrs

  items

# Normalize children and their decendants
normalize = (items) ->
  return items unless isArray items

  for i in [items.length - 1..0]
    item = normalize items[i]
    if isArray item
      if item[0] is ''
        item.shift()
        items.splice i, 1, item...
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
  newStyles = {}

  style = attrs.style
  if typeof style is 'string'
    newStyles = merge(newStyles, parseStyles(style))

  styles = attrs.styles
  if typeof styles is 'string'
    newStyles = merge(newStyles, parseStyles(styles))

  if isObject style
    newStyles = merge(newStyles, style)

  if isObject styles
    newStyles = merge(newStyles, styles)

  delete attrs.styles
  attrs.style = newStyles unless isEmpty newStyles
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

prepareOutput = (template, data) ->
  if typeof template is 'function'
    prepareOutput(template(data), data)
  else if isArray template
    if hasFunction template
      (prepareOutput(item, data) for item in template)
    else
      template
  else if isObject template
    if template.isTemplate
      prepareOutput(template.process(data), data)
    else if hasFunction template
      output = {}
      for key, value of template
        output[key] = prepareOutput(value, data)
      output
    else
      template
  else
    template

renderAttributes = (attributes) ->
  result = ""

  for own key, value of attributes
    if key is "style"
      styles = attributes.style
      if isObject styles
        s = ""
        for own name, style of styles
          s += name + ":" + style + ";"
        result += " style=\"" + s + "\""
      else
        result += " style=\"" + styles + "\""
    else result += " " + key + "=\"" + value + "\""

  result

renderRest = (input) ->
  (render(item) for item in input).join('')

render = (input) ->
  return '' if typeof input is 'undefined' or input is null
  return '' + input unless isArray input
  return '' if input.length is 0

  first = input.shift()

  return renderRest input if first is ""
  return "<" + first + "/>" if input.length is 0

  result = "<" + first

  second = input.shift()
  if isObject second
    result += renderAttributes second

    if input.length is 0
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

Template = (@template) ->
  @isTemplate = true

Template.prototype.map = (@mapper) ->
  this

Template.prototype.process = (data) ->
  data   = @mapper data if @mapper
  output = prepareOutput(@template, data)
  output = normalize output
  processAttributes output

Template.prototype.render = (data) ->
  output = @process data
  render output

Template.prototype.prepare = (@extras) ->
  @process = (data) ->
    try
      oldExtras = T.extras if T.extras
      T.extras  = extras if extras

      Template.prototype.process.call(this, data)     
    finally
      if oldExtras
        T.extras = oldExtras
      else
        delete T.extras

  this

T = (template) ->
  if typeof template is 'object' and template.isTemplate
    template
  else
    new Template(template)

T.process = (template, data) ->
  T(template).process data

T.render  = (template, data) ->
  T(template).render data

T.value = (name, defaultValue) ->
  defaultValue = null if typeof defaultValue is 'undefined'

  (data) ->
    return defaultValue unless data

    parts = name.split '.'
    for part in parts
      data = data[part]
      if typeof data is 'undefined' or data is null
        return defaultValue

    if typeof data is 'undefined' or data is null
      defaultValue
    else
      data

T.escape = (str) ->
  str
   .replace(/&/g, "&amp;" )
   .replace(/</g, "&lt;"  )
   .replace(/>/g, "&gt;"  )
   .replace(/"/g, "&quot;")
   .replace(/'/g, "&#039;")

T.unescape = (str) ->
  str
   .replace(/&amp;/ , '&')
   .replace(/&lt;/  , '<')
   .replace(/&gt;/  , '>')
   .replace(/&quot;/, '"')
   .replace(/&#039;/, "'")

T.include = (name, defaultValue) ->
  (data) ->
    T.extras?[name] or defaultValue

T.prepare = (template, extras) ->
  t = T(template)
  t.process = (data) ->
    try
      oldExtras = T.extras if T.extras
      T.extras  = extras   if extras

      Template.prototype.process.call(this, data)     
    finally
      if oldExtras
        T.extras = oldExtras
      else
        delete T.extras

  t

T.utils   =
  normalize        : normalize
  processFirst     : processFirst
  parseStyles      : parseStyles
  processStyles    : processStyles
  processAttributes: processAttributes
  render           : render

this.T = T

# Node.js exports
module?.exports = T

