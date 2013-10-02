
!SLIDE incremental title-and-content

# What is it?

* The basic idea is to render a Javascript array as HTML tag. 

  ```
  ['a', {src: '/test.html'}, 'This is a link']
  ```

  ```
  <a src='/test.html'>This is a link</a>
  ```

!SLIDE incremental

* With that in mind, you can use full Javascript's power to build up the array.

* Arrays within arrays:

  ```
  ['div', ['div', 'Header'], ['div', 'Body']]
  ```

  ```
  <div>
    <div>Header</div>
    <div>Body</div>
  </div>
  ```

