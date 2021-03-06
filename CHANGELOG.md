# Change Log

## 3.4.6 2021-07-??

### Release Notes

This release fixes the following Boxer primitives: `follow-mouse`, `handle-input`,
and `status-line-y-or-n`, as well as other primitives that depended on status line
input.

We're continuing to work on simplifying the File Menu, and have collaposed the Box Marking
portion to just option depending on whether the box is already saved to a file.  Additionally,
the Save option will perform a Save As on the World if nothing is saved yet, and prompt
for a file name (rather than be greyed out). As of now the only time the `Save` menu item
will be greyed out is if you are in a read-only file box.

This release includes in progress work of updating the way that the mouse clicks are triggered
and handled in boxer. This is currently experimental and subject to change.  On start up, the
old behavior is used, but the new 2021 Mouse Clicks can be enabled in the User Preferences
under the Editor section.  Previously all combinations of mouse clicks in Boxer had a single
`MOUSE-CLICK` magic name that could be overwritten, along with a `MOUSE-DOUBLE-CLICK`. This
used a delay on clicking to see if it would be a double click or not. Additionally, `MOUSE-CLICK`
behaved as a mouse press since you didn't have to let up on the mouse for it to register.

The new version of mouse clicks add `MOUSE-DOWN`, `MOUSE-UP` and trigger them accordingly along
with click on the way to a double click. There is no lag when clicking now. There is some work to
do on this behavior still, as it stands if you were using `MOUSE-CLICK` for dragging, you would
now use `MOUSE-DOWN`. In the end there may be some way to preserve this by changing names, or
legacy worlds may just need to be updated, or switched in to old click mode.  This work is in progress.

As part of the mouse clicks and general event loop handling improvement, this release includes a
refactoring that begins decoupling the Boxer Event Queue from the Lispworks CAPI Opengl handling. This is a first
small step towards an independent Boxer Evaluation engine that could be used with other rendering
implementations (Metal, Audio representation for hearing impaired, server side engine for use with
WebGL or the DOM, or another independent OpenGL implementation, etc)

The background color of the top left box corner was changed to a more subtle shade of yellow. As
part of this we created a new `boxer-styles.lisp` to beging centralizing all the colors, thicknesses,
and font style variables which are scattered around the source. Long term this should evovle into
a boxer style sheets type of utility to create themes, dark mode version of the boxer canvas etc.

More contributors from Boxer history were added to the top level readme.

As usual lots more code for old lisp platforms and machines was moved to the attic.  Another small
handful of crash fixes were put in.

### Full Change Log

- boxer-bugs-57 Updating background corner on top left shrink corner
    - Updated background color to RGB 1.0 0.9 0.0. A sort of dark yellow.
    - Created new file boxer-styles to start collecting styles in.
    - Updating some of the ogl color hooks to take an RGB vector, so we
      don't have to rely on in-memory opengl vectors in order to set
      preferences.

- boxer-bugs-46 Updating behavior of File Save menus
    - Rename "Mark Box as File, Save..." to "Save Box as File”
    - Collapse the "Mark box" section on the menu to just
        "Unmark This Box As File" or"Save Box as File"
            (Currently: "Mark Box as File, Save…")
    - Change "Save" to not be disabled, but if a box is not a file box,
      then have it invoke either "Save As..."      or "Save Box as File”

- boxer-bugs-51
  - Changing maximum-mouse-button-encoding to use length of defined mouse actions.
  - Removing old ~A-~A-MOUSE-~A and ~A-MOUSE-~A-ON-~A click names for platforms that
    no longer exist.
  - Updated the :lwm and :ibm-pc platforms to have mouse-up and down
  - Added a sysprims preference for switching between new and old mouse behavior
  - Added hooks in capi click methods to click depending on preference
  - Added method in keys-new to swap the set of mouse key bindings for the two

- boxer-sunrise-25 Adding mouse x, y, and down? status to dev overlay.

- boxer-sunrise-31 boxer-sunrise-19 Fixed primitives handle-input and status-line-y-or-n
    - Adding checks for gesture-specs in several places as these are what are
      generating the key events now. We should look and see if the key-event?
      conditions are even necessary anymore at some point.

- boxer-sunrise-33 Fixed follow-mouse primitive
  Fixing follow-mouse by repainting-internal since we are already inside the pane
  process which is following the mouse drag.

- boxer-sunrise-32 Added binary releases page to top-level readme.

- crash-fix
  - Null checking screen-rows array
  - Check for null  before de-allocating them

- refactor
  - Removing :boxer-input mouse parameterization.
  - Moving boxer-eval-queue and related command loops to separate file to
    allow usage outside of CAPI/opengl
  - See boxer-bugs-57 for the beginning of boxer styles centralization

- doco
  - Added more contributors to the README


- the-attic
  - Removing lispworks6 version of quit
  - Removed more old 3600, TI, and MCL code
  - Removing unused methods start-box-copyright-warning, with-open-blinkers,
    redisplayable-window?, kill-redisplayable-window from boxwin-opengl
  - Moved out old versions of commands in comsa
  - Removing old -opengl redisplay cues, and minor Symbolics and MCL calls.
  - Moving Symbolics lisp machine specific functions in ev-int to the attic.
  - Removed binhex from asdf components
  - Properly deprecating mail primitives from mail.lisp and removing to the attic.
  - Properly deprecating mailfile primitives from mailfile.lisp and removing to the attic.
  - Properly decprecating gopher support and the 2 primitives gopher.lisp provided.
    (telnet, gopher-search)
  - Move commented out force-repaint-window to the attic.
  -

## 3.4.5 2021-05-25

- boxer-bugs-38 Updating default font sizes to be closer to Boxer pre 2014.

- boxer-sunrise-49 Fixing up type-font behavior
  - Moving back to MCL era of having type-font box in sprites contain the actual human readable
    fontspec rather than an internal integer.
  - Transitioning type-font from an invalid-value boxer-interface static variable to a special-value
    boxer-interface slot with a type-font-box-updater update function
  - Fixed update-type-font trigger to behave the same as if you were calling set-type-font
  - Adding an extra check for loading in font information from saved box files.

- boxer-sunrise-22 In-progress comments and work arounds.

- boxer-sunrise-26 Improved gesture scrolling
  - Looking possibly all the way to the *outermost-screen-box* now for a box to scroll
  - Going outward if current box does not have scrollbars
  - Going outward if mouse is over a :shrunk :supershrunk or :boxtop rendered box.

- boxer-sunrise-25 Preparatory HUD information for perf and rendering fixups.

- boxer-bugs-55
  - Fixing namespace on gl-vectors usage

- boxer-bugs-52 Initial fix-up of launching xref links with default Finder actions.

- Binding accel-a, accel-b, accel-i to Select Box (All), Toggle Bold, Toggle Italics

- boxer-sunrise-21 Major set of work reworking how font-ids are stored and work.
  - Removes the bit-field implementation and replaces that with a simple list of
    opengl-fonts, and some simple operators over that list.
  - Removes any limitations on having different font sizes, faces, etc.
  - Cleanup of outdated font comments
  - Renaming boxer-font params to font-no, removing unused font-stylep function.
  - Fixing font lookup on boxer::menu-item
    - Currenty the popup menu items are being created before the *default-font*
      is bound at startup.
    - Added an accessor for slot-value 'font to lookup the *default-font* in case
      it was nil during creation.
  - Fixing up font-style, font-size, and font-name functions
  - Fixing up font zooming to use a percentage as the multiplier, rather than a sliding list of
    predefined font sizes.
  - Updating the font bigger/smaller menus to incremenet/decrement in .25 chunks with a minimum
    of 0.5 zoom and a maximum of 4x zoom.
  - Updating freetype and opengl rendering methods to take an optional font-zoom parameter.
  - Removing %font-size-idx as font-size does the same thing
  - Removing relative saving var from dumper as all fonts are actual sizes now.
  - Removing never used drawing-font-map, sheet-font-map
  - Among other leftover debt bits from fonts.lisp
  - Adding back size translations for historic relative font size saves.

- boxer-sunrise-20
  - Moving graphics Macros definitions above their first usage.
  - Adding define-constant macro to work around oddities in CL defconstant behavior
  - Internal namespace accessors on opengl items and removing use of lispworks color module.
  - More seperation of platform specific libraries

- boxer-sunrise-18
  - Swapping out lw color module for regular vectors
  - Moving clipboard functionality (including last usage of color: ) to a lw-capi specific folder.
  - Removing last used graphics-port references from draw-low-opengl and bitmap functions

- crash-fixes
  - Disabling printing right now since it's broken, and hangs the system
  - Some undefined functions were getting called causing crashes.
  - Adding an extra null check
  - Sometimes we get here and there is no screen-box on the screen-row

- tests In-progress modernizing existing chunker tests to run as real unit tests and add more
  for pipes and other characters.

- re-org
  - Moving all the primitives into the unified primitives directory.
  - Moving (re)display definitions into the common definitions folder.
  - Starting to co-locate parts of the evaluator.
  - Merging evaldefs folder with evaluator
  - Merging evalvars folder with evaluator folder
  - Moving process.lisp to evaluator folder

- documentation Starting to fill out various README's and information on bits of the system.

- Continued formatting fixes and improvements across source.

- the-attic
  - Removed old `pkg.lisp`, `update-blinker-function`, more `#-opengl` code, `window-depth` function,
    old `trig` definitions, `#+3600` code, old `*uc-copyright-free*` decprecated features, `com-fat`,
    `com-nutri-system`, old SGI versions of drawing methods, old `define-eval-var` forms, unused variables
    from `boxdef` and `vrtdef`, unused `clip-x` and `clip-y` functions,
    `interval-update-repaint-current-rows`

## 3.4.4 2021-03-12

- Installer updates and expansions
  - This release we are including an experimental windows binary which requires installing the
    "Microsoft Visual C++ Redistributable for Visual Studio 2015, 2017 and 2019". Future releases
    will properly include these in the installer itself.
    https://support.microsoft.com/en-us/topic/the-latest-supported-visual-c-downloads-2647da03-1eea-4433-9aff-95f26a218cc0
  - We are including a DMG archive for the MacOS version now, with a traditional "drag and drop the binary
    in to the applications folder" type installer.  The DMG folder dimensions and artwork are a work in progress.
  - Moving forward we'll be slowly cleaning up and including more demos and microworlds with releases.
    This release we are including the "Annotated Cube" and "Button Factory" demos.

- boxer-sunrise-16 Minor improvements to scrollbar rendering. Removing tiny up/down buttons.

- boxer-sunrise-6 Fix annoying default file name issue with Windows 10 File Chooser.
  - Updating default pathname to be a directory without default foo.bar file.

- boxer-sunrise-15 Removing currently un-needed preferences for Email setup and keyboard device configuration (lwm)

- boxer-bugs-39 Adjusting sizes to fix zooming issues.
  - Includes a crash fix when zooming down to the lowest size.
  - Fixes issue where fonts at a size 28 would render at size 8.

- boxer-bugs-3 Adding support for scroll gestures from trackpad gestures or mouse scroll wheels.

- boxer-sunrise-9
  - Updates to hover over renderings. Including some minor color contrast similar to macos max/min
    buttons and circles with solid borders for contrast
  - Cleaning up box corner clicks, refactoring pop-up menus, implementing new menu item designs.
  - Standardizing keyboard bindings across MacOS, Windows, Linux. The only minor differences going forward should stem
    from differences in the OS key (Windows, Command, etc) and Option rather than Alt, and sutble cultural differences
    as to when things should belong to Control vs Command (ie. cut n paste, etc)
  - Fixing up top right/left, bottom left corner menus based on revised designs from Andy

  - Removing mouse delays for toggling graphics and box type.
    - Toggling graphics already had a defvar *slow-graphics-toggle*, switched
      this to nil
    - Introduced a new defvar *slow-box-type-toggle* to control behavior for
      toggling box types.

- boxer-sunrise-13 Cleaning up keyboards between OS's to simplify setup.

- boxer-sunrise-12 Linux Support
  - Minor changes to allow starting up under 64-bit Lispworks for Linux/GTK.

- boxer-sunrise-11 Windows 10 Support
  - Updating start script to take in to account windows drive letters for paths, as well as the slightly
    difference directory sturcture, and load 64ofasl files for windows and 64xfasl files for MacOS
  - Minor refactoring for included library paths.

- boxer-sunrise-7 First set of work on updated HTML5 export.

- boxer-sunrise-3 Minor refactoring of JSON export to share with HTML and other export types.

- crash-fixes
  - Fixed an issue with colors not being correctly initialized before used in the opengl context
  - Added a special check for some old microworlds storing fonts with relative sizes and starting
    with font size zero.
  - Adding extra check to avoid division by zero with max-scroll-wid math

- Continued formatting fixes and improvements across source.

- the-attic
  - Moving lots of pre-opengl drawing routines from `new-borders.lisp`, `disply.lisp`, `popup.lisp` to the attic.
  - Lots of other minor removals from deprecated platforms.

## 3.4.3 2021-01-27

- boxer-sunrise-3 First set of work on JSON export format

- boxer-sunrise-4 Menu reorganization and open recent
    - Adding boxapp-data.lisp, which will store session data for boxer in
      the OS appdata dir (on MacOS will be ~/Library/Application Support/Boxer),
      such as recently opened files and such.
    - Re-organizing new, open, mark box, and save menus based on UI suggestions
      from Andy.

- boxer-sunrise-5 Major refactoring and simplification of fonts, removing old bitmap font support as well as
  abstraction layers from 2 other old font implementations.

- boxer-bugs-26 Fixes some crashes with higher unicode codepoints.
  - Several strings were being created with element type base-char.
  - Changes a make-string call in chunker.lisp to :element-type 'character
  - Changes an array for with-output-to-string in comsa.lisp to :element-type 'character

- boxer-bugs-27 Removed an erronesous 1 extra padding of pixel when calculating each
  glyph width that was causing the cursor to move forward faster than the text, as
  box names are actually rendered as a single pixmap.

- boxer-bugs-28 Fixed the CHA-HEI functions, recentering the box names.

- MacOS Big Sur
  - Applied a patch from lispworks that fixed the issue that was causing Boxer to not start up on Big Sur.

- MacOS High Sierra
  - Recompiled the libfreetype.6.dylib library on High Sierra that was causing Boxer to crash on startup.
    The same Boxer app should be working now across all Intel versions of High Sierra, Mojave, Catalina, and Big Sur.

- Windows 10 support. Fixed opengl rendering issue with pixmaps on Windows as well as several code loading issues. Close
  to fully supported now.

- crash-fixes
  - Fixed a crash that occured when clicking on the top level WORLD name row. (You can't rename the top box name.)
  - Fixed a crash that occured when trying to calculate the width of a port actual-obj that didn't exist.

- the-attic Lots of continuing cleanup in `mouse.lisp`, `comsb.lisp`, `grobjs.lisp`, `sysprims.lisp`,
  `graphics-clear.lisp`, `comdef.lisp`, `makcpy.lisp`, `mousedoc.lisp`, `boxwin-opengl.lisp`, `realprinter.lisp`,
  `comp.lisp`, `bind.lisp`,

## 3.4.2 2020-12-11

- First major round of work for supporting modern truetype and vector fonts backed by freetype2.
  Temporary transition primitive `toggle-fonts` provided to switch between old and new implementation
  in boxer.

  Remaining issues for font work:
    - Cursor location for box names is off. You can type and edit them fine, but the cursor is
      painted a bit off.
    - Advance spacing is still a bit off. Some letters get slightly chopped off, especially when
      italized.
    - Still need to find an open source verdana replacement. As of now it is also rendering with
      Liberation Sans (which is currently being used for Arial).

- Including the Liberation set of truetype fonts: San, Serif, and Monospace.

- Fixed numerous crash fixes.
    - Checking for null input in 'name-string-or-null' before attempting to get slot-value
    - Moving mouse-event defstruct above usage necessary during compilation.
    - Adding nil check in `search-upward-for-visible-row`
    - Generating status-line error rather than system error when trying to insert boxes in a name-row
    - Add nil checks for several chas and screen-rows.

- Updates toward a common-lisp agnostic boxer core than runs in sbcl along with lispworks and others
    - Several common lisp style updates flagged by sbcl (eval-when keywords, defconstant * -> +, etc)
    - Significant cleanup in package.lisp for boxer packages and exports
    - Created boxer-core asdf component for core boxer evaluator engine that runs in straight
      common lisp without dependencies on lispworks opengl, capi, and mp packages.

- Explicitly namespacing calls to lispworks libraries to prepare for general common lisp
  refactoring.

- Lots more continued source cleanup, moving duplicate code to the attic, converting header
  comments to semicolons, tabs to spaces, paredit indentation, cleaning up reader feature macros
  for old lisp platforms.

- Changing evaluator-helpful-message to use boxer-editor-message to avoid constant beeping.

- Minor change for Catalina and LW 7.1.2 to floor integer coordinates before passing them to opengl.

- Build and delivery updates, incuding a shell script and work arounds to ensure we don't
  try and load cl-freetype2 until application startup. The binary MacOS application includes a custom
  build freetype2 2.10.4 dylib with no dependencies on libpng.  Also includes a pre-compiled version
  of cl-freetype2 to avoid invoking compile-file on application startup (removed by lispworks delivery),
  as the cffi groveler compiles these on the fly. These are manual steps and need to be automated
  for the next release.

## 3.4.1 2020-10-29

- Increased scrollbar width a bit for visibility.

- Refactoring various bits to prepare for future work:
  - Namespaced all opengl calls (rather than having them as :use in the :boxer-window namespace)
    Cleaning up the separation between the evaluator and editor to streamline
    future opengl work as well as headless/server boxer and other potential
    display engines.
  - Continue cleanup of file formatting and read macro includes for
    lisp systems/architectures no longer in use.

- Fixed opml export, refactoring export so I can make some improvements and write
  my blog in boxer and export it.

- Boxer-bugs-14 Unifying cut and paste operations while retaining yank.

- Boxer-bugs-22 Added an extra check to ensure the error params are correctly
  interpreted.

- Created the ATTIC to clean up and archive commented out, but interesting
  code.

- Initial fixup of loading boxes over HTTPS. Rewrote previous custom
  code using the well tested `drakma` cl http library.

- Boxer-bugs-13 Fixed default bindings for most (if not all) magic mouse
  commands so they will no longer crash if you don't specify a custom method.
  Fixed return items so they no longer return "Wierd" items.

- Adding additional accelerator keys to the menus
    - Create new Port  cmd-shift-p
    - Flip closet      cmd-shift-os
    - Flip graphics    cmd-}
    - Flip Data/Doit   cmd-]
    - Flip Export      cmd-e
    - Zoom in          cmd-=
    - Zoom out         cmd--

- Boxer-Bugs-17 Adding back in support for changing the mouse cursor
    - In old versions of boxer, there were various options for changing the mouse
      cursors, but it seems to just be stubbed out until now.
    - Adding in support initially again to change the mouse to a crosshair for
      selecting the target of a new port. Added stubs for other keywords found
      around the code base.

- Fixed some of the keyboard macros to enable cross platform keyboard usage again.
  ie. Fixed the keyboard binding on Windows.

## 3.4.0 2020-10-06

- Boxer-Bugs-10 Fixed circular port rendering

- Boxer-Bugs-7 Fixed up `boxer-version` command, updated so it automatically pulls the
  version from the asdf component.

- Removed old expiration code.

- Fixed boxer-function-arglist issues. Fixed issue causing crash (rather than error),
  when not supplying the correct number of arguments to a boxer procedure.

- Continuing cleanup: Convertings mixed space/tab indenting to spaces, reformatting with
  paredit, removing conditionally included code from lisp implementations that are no
  longer in use.
