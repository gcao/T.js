partial1 = ['div', 'partial1']
partial2 = ['div', 'partial2']
partial3 = [
  'div' 
  -> partial2
  ['div', 'partial3']
]

window.template = [
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

console.log template

window.processed = process template
console.log processed

#console.log item for item in processed
html = render processed

console.log html

$('body').html html

