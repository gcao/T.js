partial1 = ['div', 'partial1']
partial2 = ['div', 'partial2']

template = [
  'div'
    id   : 'main'
    class: 'blue-theme'
    style:
      display: 'absolute'
  'header'
  -> partial1
  -> partial2
  'footer'
]

html = render template

console.log html

$('body').html html

