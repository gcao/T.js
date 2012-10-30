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
    (data) ->
      if true
        ['div', 'header']
    #(data) -> (['div', child] for child in [])
    partial1
    -> partial3
    ['div', 'footer']
  ]

  container.html T(template).render()

window.test2 = (container) ->
  partial = ['div', T('name') ]

  template = [
    'div'
    'test' if true
    (i for i in ['a', 'b'])...
    T(partial, -> {name: 'John Doe'})
  ]
  console.log(template)
  container.html T(template).render()
