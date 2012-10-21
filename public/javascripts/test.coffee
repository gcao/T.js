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

html = render template

console.log html

$('body').html html

