isArray    = (o) -> o instanceof Array
isFunction = (o) -> typeof (o) is "function"
isObject   = (o) -> typeof (o) is "object" and (o not instanceof Array)

# T - takes an array and returns a template object
# Example:
# T('div', 'text')
this.T = T = (items...) ->
  new T.template(items...)

T.template = (items...) ->
  this.items = items

# Compiles template into intermediate function which runs faster
# It can be called repeatedly with different options, last call will overwrite
# previous functions
# Compilation will be invoked recursively, but compiled version of partials are
# only stored where it is used 
# Example:
# template = T('div', 'text')
# template.compile()
T.template.prototype.compile = (options) ->

# If template is compiled, the intermediate function is used, 
# otherwise, default rendering function is invoked
T.template.prototype.render = (data) ->

# Add items directly inside parent array
# Example:
# partial = T('div', 'text')
# template = T('div', T.expand(partial))
T.expand = ->

# If first item is null or blank String, then it is not treated as a tag name
# T('', 'text') or T.flat('text')

# Example: 
# T.IF(function(data){return true;}, [])
# T.IF(function(data){return true;}, [], [])
# T.IF(function(data){return true;}, [], T.IF(function(data){}, [], []))

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

