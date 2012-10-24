isArray    = (o) -> o instanceof Array
isFunction = (o) -> typeof (o) is "function"
isObject   = (o) -> typeof (o) is "object" and (o not instanceof Array)
isEmpty    = (o) ->
  return true unless o
  for key of o
    return false if o.hasOwnProperty key
  return true
merge      = (o1, o2) ->
  return o1 unless o2
  return o2 unless o1

  for key, value of o2
    if o2.hasOwnProperty key
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

processFunctions = (template, data) ->
  return processFunctions(template(data), data) if isFunction(template)

  if isArray template
    (processFunctions(item, data) for i, item of template)
  else if isObject template
    result = {}
    for own key, value of template
      if isFunction value
        result[key] = processFunctions(value(data), data)
      else
        result[key] = value
  else
    template

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
    for i, item of items
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

# process could be splitted into several steps: 
# run all functions and generated functions
# parse first item 'div#id.class1.class2' into 'div', {id: 'id', 'class': 'class1 class2'}
# move children up if their first child is not a tag
# combine attributes into one (merge styles)
process = (template, data) ->
  output = processFunctions(template, data)
  normalize(output)

  if isArray template
    for i, item of template
      template[i] = process(item, data)

    # What
    # parse first into tag name and id/classes
    # combine multiple attributes hash into one 
    # attributes does not have to be immediately after tag element
    # merge css classes, styles
    # overwrite others

  else if isObject(template)
    for own key, value of template
      if isFunction value
        template[key] = process(value(data), data)

  template

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
  processFunctions : processFunctions
  normalize        : normalize
  processAttributes: processAttributes
  parseStyleString : parseStyleString
  processStyles    : processStyles

this.T = T

