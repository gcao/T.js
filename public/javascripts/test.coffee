processTemplate = (template) ->
  console.log template

  window.processed = process template
  console.log processed

  #console.log item for item in processed
  html = render processed

  console.log html

  html

window.test1 = (container) ->
  partial1 = ['div', 'partial1']
  partial2 = ['div', 'partial2']
  partial3 = [
    'div' 
    -> partial2
    ['div', 'partial3']
  ]

  template = [
    'div'
      id   : 'main'
      class: 'blue-theme'
      style:
        display: 'absolute'
    ['div', 'header']
    -> partial1
    -> partial3
    ['div', 'footer']
  ]

  container.html processTemplate template

window.test2 = (container) ->
  partial = ['div', (data) -> data.name ]

  template = [
    'div'
    include(partial, -> {name: 'John Doe'})
  ]

  container.html processTemplate template
