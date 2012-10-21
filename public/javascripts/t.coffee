isArray    = (o) -> o instanceof Array
isFunction = (o) -> typeof (o) is "function"
isObject   = (o) -> typeof (o) is "object" and (o not instanceof Array)

this.render = (template, data) ->
  return render(template(data))  if isFunction(template)
  return template  unless isArray(template)
  return  if template.length is 0

  first = template.shift()
  return "<" + first + "/>"  if template.length is 0

  result = "<" + first
  second = template.shift()
  if isObject(second)
    for key of second
      if key is "style"
        styles = second.style
        if isObject(styles)
          s = ""
          for name of styles
            s += name + ":" + styles[name] + ";"  if styles.hasOwnProperty(name)
          result += " style=\"" + s + "\""
        else
          result += " style=\"" + styles + "\""
      else result += " " + key + "=\"" + second[key] + "\""  if second.hasOwnProperty(key)
    if template.length is 0
      result += "/>"
      return result
    else
      result += ">"
  else
    result += ">"
    result += render(second, data)
    if template.length is 0
      result += "</" + first + ">"
      return result

  if template.length > 0
    for part in template
      result += render(part, data)

    result += "</" + first + ">"

  result

