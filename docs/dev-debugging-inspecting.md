# Development Debugging and Inspecting

## Inspecting the box data structures

When running boxer, the following global variables allow access to viewing the current running state, and these can
be accessed from a REPL.

- boxer::*initial-box* This is the top level root box for the entire world.
- boxer::*outermost-screen-box* This is whichever box is current full screened in the world.
- boxer::*point* This contains a structure which includes the current row and screen-box of the cursor/point which can
  be inspected.

## Restarting the boxer canvas after investigating an error

After debugging/inspecting an issue stopped execution while running Boxer in Lispworks, the world canvas can
be restarted at the REPL with:

```
(bw::boxer-process-top-level-fn bw::*boxer-pane*)
```

## Dumping the contents of a Box file

Dumping the version and opcodes of a `.box` file can be done at the REPL with:

```

```
