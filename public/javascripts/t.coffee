isArray    = (o) -> o instanceof Array
isFunction = (o) -> typeof (o) is "function"
isObject   = (o) -> typeof (o) is "object" and (o not instanceof Array)

parseFirstPattern = /^([^#.]+)?(#([^.]+))?(.(.*))?$/
parseFirst = (first) ->
  throw "Invalid first argument #{first}"  unless typeof (first) is 'string'

  if matches = first.match(parseFirstPattern)
    {tag: matches[1], id: matches[3], classes: matches[5]}
  else
    first

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
  return children  unless isArray children
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
  return processFunctions(template(data), data)  if isFunction(template)

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
  return items  unless isArray items

  console.log 'normalizeChildren'
  console.log items

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

  console.log 'after normalizeChildren'
  console.log items
  items

# Normalize top level array
normalize = (items) ->
  return items  unless isArray items

  items = normalizeChildren(items)

  console.log items
  items

# Combine attributes into one hash and move to second position of array
processAttributes = (output) ->

# process could be splitted into several steps: 
# run all functions and generated functions
# move children up if their first child is not a tag
# combine attributes into one
process = (template, data) ->
  return process(template(data), data)  if isFunction(template)

  if isArray template
    for i, item of template
      template[i] = process(item, data)
    
    # TODO, parse first into tag name and id/classes
    # combine multiple attributes hash into one 
    # attributes does not have to be immediately after tag element
    # merge css classes, styles
    # overwrite others
    # What about event handlers?

  else if isObject(template)
    for own key, value of template
      if isFunction value
        template[key] = process(value(data), data)

  template

render = (template, data) ->
  return template  if typeof (template) is "string"
  return "" + template  unless isArray(template)
  return  if template.length is 0

  first  = template.shift()

  return renderChildren template, data  if first is ""
  return "<" + first + "/>"  if template.length is 0

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
  processFunctions : processFunctions
  normalize        : normalize
  processAttributes: processAttributes

this.T = T

