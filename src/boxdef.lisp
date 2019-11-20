;; -*- Mode:LISP; Syntax:Common-Lisp; Package:(BOXER :USE (LISP) :NICKNAMES (BOX)) -*-
#|

 $Header: boxdef.lisp,v 1.0 90/01/24 22:06:55 boxer Exp $

 $Log:	boxdef.lisp,v $
;;;Revision 1.0  90/01/24  22:06:55  boxer
;;;Initial revision
;;;










 Copyright 1982 - 1985  Massachusetts Institute of Technology

 Permission to use, copy, modify, distribute, and sell this software
 and its documentation for any purpose is hereby granted without fee,
 provided that the above copyright notice appear in all copies and that
 both that copyright notice and this permission notice appear in
 supporting documentation, and that the name of M.I.T. not be used in
 advertising or publicity pertaining to distribution of the software
 without specific, written prior permission.  M.I.T. makes no
 representations about the suitability of this software for any
 purpose.  It is provided "as is" without express or implied warranty.



 Copyright 1986 - 1998 Regents of the University of California

 Enhancements and Modifications Copyright 1998 - 2013 PyxiSystems LLC

                                         +-Data--+
                This file is part of the | BOXER | system
                                         +-------+


 This file contains the defs for Boxer.


Modification History (most recent at top)

 7/17/13 removed *{bold,italics,tiny}-font-no* vars, clarifying comment for boxer-font-descriptor
 3/17/12 added new fill-row class for text justification hacking
 3/ 6/11 added (defvar *boxtop-text-font*) to keep all the defined font vars
         in the same place
 no more sprite boxes
 changed graphics-sheet slot in BOX class to "graphics-info"
 9/13/05 added more stuff to define-box-flag for new show-box-flags method
 2/10/03 PC & mac source merge
 9/01/02 added *uc-copyright-free*
 4/16/02 added intern-keyword
 3/20/02 added shrink-on-exit? flag
 3/15/02 added always-zoom? box flag
 1/27/02 added bit-array-dirty? flag to graphics-sheet structure def
 6/24/98 changed values for *minimum-box-wid/hei*
 6/24/98 started logging changes: source = boxer version 2.3


|#

#-(or lispworks mcl lispm) (in-package 'boxer :use '(lisp) :nicknames '(box))
#+(or lispworks mcl)       (in-package :boxer)





;;
;; this could be a lot faster, we should be able to do a compile time
;; check to see if TYPE is a class and then put in the appropriate code instead
;; of the OR which is there now.

#-(and lucid clos)
(defmacro fast-iwmc-class-p (thing)
  (warn "You need to define a version of FAST-IWMC-CLASS-P for ~A of ~A"
	(lisp-implementation-version) (lisp-implementation-type))
  `(typep ,thing 'structure))


;;; +++ temp
#+mcl
(defun expand-mcl-type-check (var type class)
  (declare (ignore class))
  `(typep ,var ',type))

#+pcl
(defun expand-pcl-type-check (var type class)
  (if (typep class 'block-compile-class)
      (let* ((c&s-symbol
	      (pcl::bcm-class-and-instantiable-superiors-symbol class))
	     (c&s (symbol-value c&s-symbol)))
	(cond ((null c&s)
	       (warn "~%The class ~A claims to not be instantiable" class)
	       nil)
	      ((= 1 (length c&s))
	       `(and (pcl::iwmc-class-p ,var)
		     (eq (pcl::wrapper-class
			   (pcl::iwmc-class-class-wrapper ,var))
			 (car ,c&s-symbol))))
	      (t
	       `(and (pcl::iwmc-class-p ,var)
		     (member (pcl::wrapper-class
			       (pcl::iwmc-class-class-wrapper ,var))
			     ,c&s-symbol :test #'eq)))))
      `(and (pcl::iwmc-class-p ,var) (typep ,var ',type))))

(defvar *include-compiled-type-checking* t)

;; now does the compile time check for PCL-ness
(defmacro deftype-checking-macros (type type-string)
  (let ((predicate-name (intern (symbol-format nil "~a?" type)))
	(check-arg-name (intern (symbol-format nil "CHECK-~a-ARG" type)))
	(bcm-class (let ((class (find-class type nil)))
		     (when (typep class 'block-compile-class)
		       class))))
    `(progn
       (defsubst  ,predicate-name (x)
	 ,(if (null bcm-class)
	      `(typep x ',type)
	      (#+clos expand-clos-type-check #+pcl expand-pcl-type-check
               #+mcl expand-mcl-type-check
               'x type bcm-class)))
       (defmacro  ,check-arg-name (x)
	 ,(when *include-compiled-type-checking*
	    ``(check-type ,x  (satisfies ,',predicate-name) ,,type-string))))))





;;;; Boxer Object Definitions
;;;  These are low level SUBCLASSes designed to be combined into higher level
;;;  BOXER objects Which eventually get instantiated

;;;  This gives BOXER objects their very own PLIST

(defclass plist-subclass
	  ()
  ((plist :initform nil :accessor plist))
  (:metaclass block-compile-class)
  #-lispworks5(:abstract-class t))



;;; This has Slots That are used by the Virtual Copy Mechanism.

(defclass virtual-copy-subclass
    ()
  ((virtual-copy-rows :initform nil)
   (contained-links :initform nil
		    :accessor contained-links)
   (branch-links :initform nil
		 :accessor branch-links))
  (:metaclass block-compile-class)
  #-lispworks5(:abstract-class t)
  (:documentation "Interface to virtual copy"))

;; All of the methods are defined in the virtcopy files



;;;; Stuff that is particular to boxer.

;;;; DEFVARS

(defvar *time-zone* 8) ;Pacific Time Zone by default

(DEFVAR *INSIDE-LISP-BREAKPOINT-P* NIL)

(DEFVAR *EVALUATION-IN-PROGRESS?* NIL
  "This is bound to T by the top level DOIT command")

(DEFVAR *POINT* NIL)

(DEFVAR *MARK* NIL)

(DEFVAR *CURSOR-BLINKER-WID* 3.)

(DEFVAR *CURSOR-BLINKER-MIN-HEI* 12.)

(DEFVAR *MINIMUM-CURSOR-HEIGHT* 12.
  "The minimum height to draw the cursor so that it doesn't dissapear.")

(DEFVAR *MINIMUM-BOX-WID* 35. ; 25. ; changed to allow room for type label
  "The minimum width any box will be drawn on the screen.")

;;; +++ This depends on the height of the default font.  An alternative would be to change
;;; box-borders-minimum-size or whatever to look at the font, but I wasn't sure of that.
(DEFVAR *MINIMUM-BOX-HEI* #+MCL 30. #-MCL 25
  "The minimum height any box will be drawn on the screen.")

(DEFVAR *MULTIPLICATION* 1)

(DEFVAR *COM-MAKE-PORT-CURRENT-PORT* NIL
  "This variable is used to store newly created ports until they are inserted into the
   World. ")

(DEFVAR *BOXER-READTABLE* (COPY-READTABLE nil))

(defvar *print-boxer-structure* nil
  "Controls how verbose to print boxer structures (like *print-array*)")

(DEFVAR *INITIAL-BOX* NIL
  "The initial box the editor starts with, this box cannot be deleted
   killed etc.")

(DEFVAR *CURRENT-SCREEN-BOX* NIL
  "The Lowest Level Screen Box Which Contains the *Point*")

(DEFVAR *MARKED-SCREEN-BOX* NIL
  "The Lowest Level Scren Box Which Contains the *mark*")

(DEFVAR *BOXER-FUNCTIONS* NIL
  "This variable contains a list of symbols for all the
   lisp functions imported to Boxer.")

(DEFVAR *EDITOR-NUMERIC-ARGUMENT* NIL
  "Stores the value of whatever numeric argument for an editor function has accumalated. ")

;;;Region Variables

(DEFVAR *CURRENT-EDITOR-REGION* NIL)

(DEFVAR *REGION-BEING-DEFINED* NIL
  "Bound to a region which is in the process of being delineated.  NIL Otherwise.")

(DEFVAR *KILLED-REGION-BUFFER* NIL
  "this should be integrated into the generic kill buffer eventually")

(DEFVAR *HIGHLIGHT-YANKED-REGION* NIL
  "Controls whether freshly yanked back region should be highlighted. ")

(DEFVAR *REGION-LIST* NIL)

(defvar *following-mouse-region* nil)


;;;; Variables Having To Do With Redisplay.

(DEFVAR *REDISPLAY-WINDOW* NIL
  "Inside of REDISPLAYING-WINDOW, this variable is bound to the window
   being redisplayed.")

(DEFVAR *OUTERMOST-BOX* NIL
  "Inside of REDISPLAYING-WINDOW, this variable is bound to the window
   being redisplayed's outermost-box. This is the box which currently
   fills that window.")

(DEFVAR *OUTERMOST-SCREEN-BOX* NIL
  "Inside of REDISPLAYING-WINDOW, this variable is bound to the window
   being redisplayed's outermost-screen-box. This is the screen box which
   represents that window outermost-box.")

(DEFVAR *REDISPLAY-CLUES* NIL
  "A list of redisplay-clues. This are hints left behind by the editor
   to help the redisplay code figure out what is going on.")

(DEFVAR *COMPLETE-REDISPLAY-IN-PROGRESS?* NIL
  "Binding this variable to T around a call to redisplay will 'force'
   the redisplay. That is it will cause a complete redisplay of the
   screen. FORCE-REDISPLAY-WINDOW uses this.")

(DEFVAR *SPACE-AROUND-OUTERMOST-SCREEN-BOX* #-mcl 9.  #+mcl 3.
  "This is the number of pixels between the outside of the outermost screen
   box and the inside of the window. This space exists to allow the user to
   move the mouse out of the outermost box.")

(DEFVAR *TICK* 0
  "This is the global variable used by the (TICK) function to generate
   a continuously increasing series of integers. This is mostly used by
   the redisplay code although it wouldn't mess things up if (TICK)
   was called by other sections of code.")

(DEFVAR *BOX-ZOOM-WAITING-TIME* 0.1
  "The amount of time spent waiting between the individual steps when zooming a box. ")

(defvar *egc-enabled?* #+mcl t #+lucid t #-(or mcl lucid) nil)

(DEFVAR *CONTROL-CHARACTER-DISPLAY-PREFIX* #\
  "For display of control characters (all of them until we decide on different prefixes")

(defun tick (&optional how-many)
  (declare (ignore how-many))
  (setq *tick* (+ *tick* 1)))

(DEFVAR *OUTERMOST-SCREEN-BOX-STACK* NIL
  "Keeps track of the previous outermost screen boxes so that they can be returned to. ")

(DEFVAR *GRAY* nil
  "Bound to a window system specific tiling pattern used for drawing shrunken boxes")

;;;; Fonts

;;; The editor interface to fonts is via font numbers (small fixnums) are
;;; used as an index into a per window array of fonts
;;; The variables defined below are basically the bare minimum that
;;; we would like to support.
;;; These refer to the *boxer-pane*'s font map, the *name-pane*'s font map
;;; need only be of length 1
;;; Note that it is some of these fonts might me identical and that it is
;;; up to whatever initializes the font map in boxwin-xxx to "do the right
;;; thing"

;;; NOTE: 3/6/11 these initial values are meaningless, expect all these vars
;;;       to be initialized in a draw-low-xxx file

(defvar *normal-font-no* 0)

;; the mac versions are setup in draw-low-mcl.lisp
(defvar *box-border-label-font-no* #-mcl 4)

;; avoid problems with italics overstriking the
;; right edge of the name tab on the mac
;; fix this later by when we redo the font/char interface
(defvar *box-border-name-font-no* #-mcl 3 )


(defvar *sprite-type-font-no* 1)

(defvar *default-font-map-length* 10)

(defvar *boxtop-text-font* 1)


;;;editor variables...

(DEFVAR *COLUMN* 0
  "the cha-no of the point for use with cntrl-p and cntrl-n")

(defvar *word-delimiters* (do ((i 31 (1+ i))
			       (list nil))
			      ((= i 256) list)
			    (when (and (standard-char-p (code-char i))
				       (not (alphanumericp (code-char i))))
			      (push (code-char i) list))))


(DEFVAR *BOXER-VERSION-INFO* NIL
  "This variable keeps track of what version of boxer is currently loaded
   and being used.  Versions for general release are numbered while specific
   development versions have associated names.")

(defvar *boxes-being-temporarily-deleted* nil
  "This variable is bound to T inside editor commands that delete
   but then re-insert boxes.")



;;; STEPPING VARS

(defvar *step-flag* nil
  "Controls whether the (interim) stepper is in operation.")

(defvar *box-copy-for-stepping* nil
  "Should be an evaluator variable, when we have one.  A
   copy of the the currently-executing box, placed in the stepping
   window.  The :funcall method needs the actual box so it can
   flash lights inside it.")




;; a function or list of functions to be run after the evaluator exits
;; (so far) used in boxwin-mcl to process inout recieved during eval
(defvar *post-eval-hook* nil)

;;; debugging variables
(defvar *boxer-system-hacker* nil)

(defvar *uc-copyright-free* t)

;;;; EDITOR OBJECT DEFINITIONS

;;; see the file chars-xxx.lisp for details on how characters work in Boxer

;;; This Subclass is neccessary for an Editor Object to be redisplayed


(defclass actual-obj-subclass
    ()
  ((screen-objs :initform nil
		:accessor actual-obj-screen-objs)
   (tick :initform 1
	 :accessor actual-obj-tick))
  (:metaclass block-compile-class)
  #-lispworks5(:abstract-class t)
  (:documentation "Used by editor objects to interface with the redisplay" ))

;;;; Instantiable Objects...

(defclass row
    (actual-obj-subclass  plist-subclass)
  ((superior-box :initform nil :accessor superior-box :initarg :superior-box)
   (previous-row :initform nil :accessor previous-row :initarg :previous-row)
   (next-row :initform nil :accessor next-row :initarg :next-row)
   (chas-array :initform nil :accessor chas-array :initarg :chas-array)
   (cached? :initform nil :accessor cached?)
   (cached-chas :initform nil :accessor cached-chas)
   (cached-chunks :initform nil :accessor cached-chunks)
   (cached-eval-objs :initform NIL :accessor cached-eval-objs)
   (cached-evrow :initform nil :accessor cached-evrow)
   (inferior-links :initform nil))
  (:metaclass block-compile-class))

(defclass name-row
    (row)
  ((cached-name :initform nil :accessor cached-name :initarg :cached-name))
  ;; used for environmental info--a symbol in the BU package
  (:metaclass block-compile-class))

(defclass fill-row
    (row)
  ()
  (:metaclass block-compile-class))

;; changed graphics-sheet to graphics-info to hold all graphical
;; objects - name change should help catch undone things

(defclass box
    (virtual-copy-subclass actual-obj-subclass plist-subclass)
  ((superior-row :initform nil :accessor superior-row :initarg :superior-row)
   (first-inferior-row :initform nil :accessor first-inferior-row
		       :initarg :first-inferior-row)
   (cached-rows :initform nil :accessor cached-rows)
   (ports :initform nil :accessor ports)
   (display-style-list :initform (make-display-style)
		       :accessor display-style-list)
   (name :initform nil :accessor name)
   (static-variables-alist :initform nil :accessor static-variables-alist)
   (exports :initform nil :accessor exports)
   (closets :initform nil :accessor closets :initarg :closets)
   (region :initform nil :accessor region)
   (cached-code :initform nil :accessor cached-code)
   (static-variable-cache :initform nil :accessor static-variable-cache)
   (trigger-cache :initform nil :accessor trigger-cache)
   (current-triggers :initform nil :accessor current-triggers)
   (graphics-info :initform nil :accessor graphics-info)
   (flags :initform 0 :accessor box-flags))
  (:metaclass block-compile-class))

(defclass doit-box
	  (box)
     ()
  (:metaclass block-compile-class))

(defclass data-box
	  (box)
     ()
  (:metaclass block-compile-class))


(defclass port-box
	  (box)
     ()
  (:metaclass block-compile-class))

#| No more sprite boxes !!!
;;; Just add a slot for the turtle to a normal box
(defclass sprite-box
    (box)
  ((associated-turtle :initform nil :initarg :associated-turtle
		      :accessor sprite-box-associated-turtle))
  (:metaclass block-compile-class))
|#


;; for delineating regions in the editor...

(defstruct (interval
	    (:predicate interval?)
	    (:copier nil)
	    (:print-function print-interval)
	    (:constructor %make-interval (start-bp stop-bp)))
  (start-bp nil)
  (stop-bp nil)
  (visibility nil)
  (blinker-list nil)
  (box nil))

(defun print-interval (interval stream level)
  (declare (ignore level))
  (format stream "#<INTERVAL [~A,~D] [~A,~D]>"
	  (bp-row (interval-start-bp interval))
	  (bp-cha-no (interval-start-bp interval))
	  (bp-row (interval-stop-bp interval))
	  (bp-cha-no (interval-stop-bp interval))))


(defstruct (graphics-sheet (:constructor
			    %make-simple-graphics-sheet
			    (draw-wid draw-hei superior-box))
			   (:constructor %make-graphics-sheet-with-bitmap
			    (draw-wid draw-hei bit-array superior-box))
			   (:constructor
			    %make-graphics-sheet-with-graphics-list
			    (draw-wid draw-hei superior-box))
			   (:constructor make-graphics-sheet-from-file
			    (draw-wid draw-hei draw-mode))
			   (:copier nil)
			   (:print-function
			     (lambda (gs s depth)
			       (declare (ignore depth))
			       (format s "#<Graphics-Sheet W-~D. H-~D.>"
				       (graphics-sheet-draw-wid gs)
				       (graphics-sheet-draw-hei gs)))))
  (draw-wid *default-graphics-sheet-width*)
  (draw-hei *default-graphics-sheet-height*)
  (screen-objs nil)
  (bit-array nil)
  (object-list nil)
  (superior-box nil)
  (draw-mode #+gl ':window #-gl ':wrap)
  (graphics-list nil)
  (background nil)
  (colormap nil)
  (transform nil) ; opengl transform matrix

  ;; these are obsolete....
  (prepared-flag nil)
  ;; used to avoid redundant prepare sheets (see bu::with-sprites-hidden)
  (bit-array-dirty? nil)
  ;; used to avoid saving cleared bitmap backgrounds
  )

;; this can stay here cause its for a Struct and not a PCL Class
(deftype-checking-macros GRAPHICS-SHEET "A Bit Array for Graphics Boxes")



;;;; Flags

;;; if we use bit positions in a fixnum for various boolean values of
;;; a box, we can save A LOT OF SPACE at a modest cost in speed.
;;; Right now, each flag costs a word of storage vs 1 bit
;;; The speed cost is about an extra 12 MC68020 (10 sparc instructions)
;;; per flag reference

(defvar *defined-box-flags* (make-array 32 :initial-element nil))

(defmacro define-box-flag (name position)
  `(progn
     (setf (svref *defined-box-flags* ,position) ',name)
     (defsubst ,(intern (symbol-format nil "BOX-FLAG-~A" name)) (word)
       (not (zerop& (ldb& ',(byte 1 position) word))))
     (defsubst ,(intern (symbol-format nil "SET-BOX-FLAG-~A" name)) (word t-or-nil)
       (dpb& (if t-or-nil 1 0) ',(byte 1 position) word))
     (defmethod ,name ((self box))
       (not (zerop& (ldb& ',(byte 1 position) (slot-value self 'flags)))))
     (defmethod ,(intern (symbol-format nil "SET-~A" name)) ((self box) t-or-nil)
       (setf (slot-value self 'flags)
	     (dpb& (if t-or-nil 1 0)
		  ',(byte 1 position)
		  (slot-value self 'flags)))
       t-or-nil)
     (defmethod (setf ,name) (t-or-nil (self box))
       (setf (slot-value self 'flags)
	     (dpb& (if t-or-nil 1 0)
		  ',(byte 1 position)
		  (slot-value self 'flags)))
       t-or-nil)))

(define-box-flag shrink-proof? 0)

(define-box-flag build-template? 1)

(define-box-flag storage-chunk? 2)

(define-box-flag load-box-on-login? 3)

(define-box-flag read-only-box? 4)

(define-box-flag copy-file? 5)

(define-box-flag foreign-server 6)

(define-box-flag fake-file-box 7)

(define-box-flag file-modified? 8)

;; similiar to load-on-login? but we want to avoid conflicts with client code
(define-box-flag autoload-file? 9)

;; a flag which tells the printer that the box and all it's inferiors
;; is guaranteed to be freshly CONSed with no links to any other existing
;; editor structure.  It is therefore OK to just incorporate the box into
;; the printed result without copying
(define-box-flag all-new-box? 10)

;; closet locks

(defvar *lock-all-closets* t)

(define-box-flag locked-closet? 11)

;; support for local control of hotspots
(define-box-flag top-left-hotspot-active?     12)
(define-box-flag top-right-hotspot-active?    13)
(define-box-flag bottom-left-hotspot-active?  14)
(define-box-flag bottom-right-hotspot-active? 15)
(define-box-flag type-tag-hotspot-active?     16)

(define-box-flag auto-fill?                   17)

(define-box-flag relative-filename?           18)

(define-box-flag always-zoom?                 19)
(define-box-flag shrink-on-exit?              20)

(defmethod show-box-flags ((self box) &optional show-all?)
  (let ((flags (slot-value self 'flags)))
    (dotimes (i (length *defined-box-flags*))
      (let ((name (svref *defined-box-flags* i)))
        (cond ((null name))
              (t (let ((flag-set? (not (zerop (ldb (byte 1 i) flags)))))
                   (cond ((and (null show-all?) (null flag-set?)))
                         (t (format t "~&~A: ~A" name
                                    (if flag-set? "true" "false")))))))))))

;; move graphics-view? here ?



;;;BP's are pointers which are used to move within REAL(that is, ACTUAL)
;;;structure.  Note that they have nothing to do with SCREEN structure...
;;;The *point* is a BP as is the *mark*
;;;however, operations which move the *point* and the *mark* also update the
;;;global variable's  *current-screen-box* and *marked-screen-box*

(DEFSTRUCT (BP (:TYPE LIST) :NAMED          ;Easier to Debug
	       (:CONSTRUCTOR MAKE-BP (TYPE))
	       (:CONSTRUCTOR MAKE-INITIALIZED-BP (TYPE ROW CHA-NO))
	       (:CONC-NAME   BP-))
  (ROW    NIL)
  (CHA-NO 0)
  (SCREEN-BOX NIL)
  (TYPE ':FIXED))

(DEFSUBST BP? (X)
  (AND (CONSP X) (EQ (CAR X) 'BP)))

(DEFMACRO CHECK-BP-ARG (X)
  `(CHECK-TYPE ,X (SATISFIES BP?) "A Boxer Editor Buffer-Pointer (BP)."))

(defsubst row-bps (row) (bps row))

(defsetf row-bps set-bps)
;(DEFSETF ROW-BPS (ROW) (NEW-BPS) `(SET-BPS ,ROW ,NEW-BPS))


#|

;;; These are here because of lossage in the franz expansion of defstructs
;;; with the :type option set
#+excl
(defsetf bp-row (bp) (new-row) `(setf (nth 1 ,bp) ,new-row))
#+excl
(defsetf bp-cha-no (bp) (new-cha-no) `(setf (nth 2 ,bp) ,new-cha-no))
#+excl
(defsetf bp-screen-box (bp) (new-screen-box) `(setf (nth 3 ,bp) ,new-screen-box))
#+excl
(defsetf bp-type (bp) (new-type) `(setf (nth 4 ,bp) ,new-type))

|#


(defmacro move-bp (bp form)
  `(multiple-value-bind (new-row new-cha-no new-screen-box)
       ,form
     (when (row? new-row)
       (move-bp-1 ,bp new-row new-cha-no new-screen-box))))

(defmacro move-point (form)
  `(multiple-value-bind (new-row new-cha-no new-screen-box)
       ,form
     (when (row? new-row)
       (move-point-1 new-row new-cha-no new-screen-box))))

(DEFUN BP-CHA (BP)
  (CHA-AT-CHA-NO (BP-ROW BP) (BP-CHA-NO BP)))




;;;; Font Descriptors
;;; This is the main datastructure for specifying font info in the editor
;;; Note that the "size" encoded in the font-no is relative, see
;;; These are stored in a slot in the chas-array (like BP's) and need to
;;; be updated (like BP's) by things like SLIDE-CHAS-ARRAY-CHAS

;; a draw-low-xxx variable, defined here to suppress warnings in the following
;; Defstruct
(defvar *foreground-color*)

(defstruct (boxer-font-descriptor (:conc-name bfd-)
				  (:predicate bfd?)
				  (:constructor make-bfd (cha-no font-no))
                                  (:constructor make-cfd (cha-no font-no color))
				  (:print-function
				   (lambda (bfd stream depth)
				     (declare (ignore depth))
				     (format stream "#<Bfd ~D ~X ~X>"
					     (bfd-cha-no bfd)
					     (bfd-font-no bfd)
                                             (bfd-color bfd)))))
  (cha-no 0 :type fixnum)
  (font-no 0 :type fixnum)
  (color *foreground-color*))

(defvar *default-font-descriptor* nil
  "The font descriptor used when no FD is explicitly specified")

(defvar *current-font-descriptor* nil
  "The font descriptor used by newly inserted characters")

;;;
;;; package stuff that would be in pkg except it must be compiled
;;;

(defun intern-in-boxer-user-package (symbol)
  (intern (string symbol) 'boxer-user))
(defun intern-in-bu-package (symbol)
  (intern (string symbol) 'bu))

(defun intern-keyword (symbol-or-string)
  (intern (if (symbolp symbol-or-string)
              (string symbol-or-string)
              (string-upcase symbol-or-string))
          'keyword))



;;;; Box Interface Structures

;;; these can be found in static-variable-alists
;;; they have 4 slots:
;;;
;;; . a Type slot
;;;
;;; . a pointer to the "real" value
;;;
;;; . a pointer to the "interface" box (or NIL)
;;;
;;; . a pointer to the superior-box that the "interface" box is intended
;;;   to live in (if it ever get created)
;;;

;;;
;;; There are 3 flavors of these interface boxes
;;; the difference between them has to do with whether or not
;;; the raw VALUE is a legitimate boxer object (usually a number)
;;; This issue arises when we want to virtual copy the box-interface
;;; object.  We can avoid CONSing the box and just return the raw
;;; VALUE iff the value doesn't depend on EQness AND it is a valid
;;; boxer object.  The port-to case will force the creation of the Box
;;; no matter what.
;;;
;;; Some interface boxes have special properties that are NOT represented
;;; by the usual text representation of boxes (usually graphical).  The
;;; interface structs for these boxes have an additional slot which contains
;;; the function used to convert between the "real" value and the particular
;;; special box property.  The back conversion (box ==> "real" value) is
;;; handled by the update function on the modified trigger of the interface box
;;;

(defmacro box-interface-type (bi) `(svref& ,bi 0))

(defmacro box-interface-value (bi) `(svref& ,bi 1))

(defmacro box-interface-box (bi) `(svref& ,bi 2))

(defmacro box-interface-sup-box (bi) `(svref& ,bi 3))

(defmacro box-interface-slot-name (bi) `(svref& ,bi 4))

(defun %make-vv-box-interface (value &optional slot-name (sup-box nil))
  (let ((bi (make-array 5)))
    (setf (svref& bi 0) 'valid-value-box-interface)
    (setf (box-interface-value     bi) value)
    (setf (box-interface-box       bi) nil)
    (setf (box-interface-sup-box   bi) sup-box)
    (setf (box-interface-slot-name bi) slot-name)
    bi))

(defun %make-iv-box-interface (value &optional slot-name (sup-box nil))
  (let ((bi (make-array 5)))
    (setf (svref& bi 0) 'invalid-value-box-interface)
    (setf (box-interface-value     bi) value)
    (setf (box-interface-box       bi) nil)
    (setf (box-interface-sup-box   bi) sup-box)
    (setf (box-interface-slot-name bi) slot-name)
    bi))

(defsubst vv-box-interface? (thing)
  (and (simple-vector-p thing)
       (eq (svref& thing 0) 'valid-value-box-interface)))

(defsubst iv-box-interface? (thing)
  (and (simple-vector-p thing)
       (eq (svref& thing 0) 'invalid-value-box-interface)))

(defsubst sv-box-interface? (thing)
  (and (simple-vector-p thing)
       (eq (svref& thing 0) 'special-value-box-interface)))

(defsubst box-interface? (thing)
  (and (simple-vector-p thing)
       (or (eq (svref& thing 0) 'valid-value-box-interface)
	   (eq (svref& thing 0) 'invalid-value-box-interface)
	   (eq (svref& thing 0) 'special-value-box-interface))))

(defmacro special-box-interface-update-function (bi) `(svref& ,bi 5))

(defun %make-sv-box-interface (value &optional slot-name (sup-box nil)
				     update-fun)
  (let ((bi (make-array 6)))
    (setf (svref& bi 0) 'special-value-box-interface)
    (setf (box-interface-value     bi) value)
    (setf (box-interface-box       bi) nil)
    (setf (box-interface-sup-box   bi) sup-box)
    (setf (box-interface-slot-name bi) slot-name)
    (setf (special-box-interface-update-function bi) update-fun)
    bi))