# Development Notes

## Running cl-opengl examples

In portacle the following can be run.  You do need to have freeglut or some
other package that includes libglut3 installed.

On Ubuntu this can be installed with `apt-get install freeglut3`.

```lisp
(ql:quickload 'cl-opengl)
(asdf:load-system 'cl-glut-examples)
(cl-glut-examples:run-examples)
```

## Running the lispworks opengl examples

```lisp
(load (example-file "opengl/examples/load"))
(setf v (capi:display (make-instance 'icosahedron-viewer)))
```
