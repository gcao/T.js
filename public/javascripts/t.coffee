isArray    = (o) -> o instanceof Array
isFunction = (o) -> typeof (o) is "function"
isObject   = (o) -> typeof (o) is "object" and (o not instanceof Array)

isEmpty    = (o) ->
  return true unless o
  for own key of o
    return false
  return true

hasFunction = (o) ->
  return true if isFunction o

  if isArray o
    for item in o
      return true if hasFunction item

  else if isObject o
    for own key, value of o
      return true if hasFunction value

merge      = (o1, o2) ->
  return o1 unless o2
  return o2 unless o1

  for own key, value of o2
    o1[key] = value

  o1

FirstFieldPattern = /^([^#.]+)?(#([^.]+))?(.(.*))?$/

# Parse first item and add parsed data to array
processFirst = (items) ->
  first = items[0]

  throw "Invalid first argument #{first}" unless typeof (first) is 'string'

  if matches = first.match(FirstFieldPattern)
    tag     = matches[1]
    id      = matches[3]
    classes = matches[5]
    if id or classes
      attrs = {}
      attrs.id    = id if id
      attrs.class = classes.replace('.', ' ') if classes
      items.splice 0, 1, tag, attrs
  else
    first

  items

renderAttributes = (attributes, data) ->
  result = ""

  for own key, value of attributes
    if key is "style"
      styles = attributes.style
      if isObject(styles)
        s = ""
        for own name, style of styles
          s += name + ":" + style + ";"
        result += " style=\"" + s + "\""
      else
        result += " style=\"" + styles + "\""
    else result += " " + key + "=\"" + value + "\""

  result

renderChildren = (children, data) ->
  return children unless isArray children
  result = ""
  for item in children
    result += render(item)
  result

include = (template, mapper) ->
  wrapFunc = (data) ->
    if mapper
      process(template, mapper(data))
    else
      process(template, data)

  # Keep a reference to the template and the mapper so that compilation could access them
  wrapFunc.template = template
  wrapFunc.mapper = mapper
  wrapFunc

# Normalize children and their decendants
normalizeChildren = (items) ->
  return items unless isArray items

  for i in [items.length - 1..0]
    item = normalizeChildren items[i]
    if isArray item
      if item[0] is ''
        item.shift()
        items.splice i, 1, item...
    else if typeof item is 'undefined' or item is null or item is ''
      #items.splice i, 1
    else
      items[i] = item

  items

# Normalize top level array
normalize = (items) ->
  return items unless isArray items

  normalizeChildren(items)

parseStyleString = (str) ->
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
    newStyles = merge(newStyles, parseStyleString(style))

  styles = attrs.styles
  if typeof styles is 'string'
    newStyles = merge(newStyles, parseStyleString(styles))

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
    processFirst items
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
  if isFunction template
    prepareOutput(template(data), data)
  else if isArray template
    if hasFunction template
      (prepareOutput(item, data) for item in template)
    else
      template
  else if isObject template
    if hasFunction template
      output = {}
      for key, value of template
        output[key] = prepareOutput(value, data)
      output
    else
      template
  else
    template

process = (template, data) ->
  output = prepareOutput(template, data)
  output = normalize(output)
  output = processAttributes(output)

render = (template, data) ->
  return template if typeof (template) is "string"
  return "" + template unless isArray(template)
  return if template.length is 0

  first  = template.shift()

  return renderChildren template, data if first is ""
  return "<" + first + "/>" if template.length is 0

  result = "<" + first

  second = template.shift()
  if isObject(second)
    result += renderAttributes(second)

    if template.length is 0
      result += "/>"
      return result
    else
      result += ">"
  else
    result += ">"
    result += renderChildren([second], data)
    if template.length is 0
      result += "</" + first + ">"
      return result

  if template.length > 0
    result += renderChildren(template, data)
    result += "</" + first + ">"

  result

T         = ->
T.include = include
T.process = process
T.render  = render
T.utils   =
  isEmpty          : isEmpty
  processFirst     : processFirst
  normalize        : normalize
  processAttributes: processAttributes
  parseStyleString : parseStyleString
  processStyles    : processStyles

this.T = T

