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
  # TODO how does reduce work?
  #children.reduce (s, item) -> s + render(item)

this.process = (template, data) ->
  return process(template(data))  if isFunction(template)

  if isArray template
    for i, item of template
      template[i] = process(item)
    
    # TODO, parse first into tag name and id/classes
    # combine multiple attributes hash into one
    # merge css classes, styles
    # overwrite others
    # What about event handlers?

  else if isObject(template)
    for own key, value of template
      if isFunction value
        template[key] = process(value(data))

  template

this.render = (template, data) ->
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

