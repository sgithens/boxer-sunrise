;; -*- Mode:LISP; Syntax:Common-Lisp; Package:BOXER; -*-
#|


 $Header: grupfn.lisp,v 1.0 90/01/24 22:13:00 boxer Exp $

 $Log:	grupfn.lisp,v $
;;;Revision 1.0  90/01/24  22:13:00  boxer
;;;Initial revision
;;;





      Copyright 1987 - 1998 Regents of the University of California

 Enhancements and Modifications Copyright 1998 - 2003 Pyxisystems LLC


                                      +-Data--+
             This file is part of the | BOXER | system
                                      +-------+



      This file contains sprite slot update functions




Modification History (most recent at top)

 4/19/03 merged current LW and MCL sources
 5/05/98 type-font fixes to handle new fonts
 5/05/98 started logging: source = Boxer version 2.3


|#

#-(or lispworks mcl lispm) (in-package 'boxer :use '(lisp) :nicknames '(box))
#+(or lispworks mcl)       (in-package :boxer)




(defun no-interface-box-error (box-name turtle)
  (error "There doesn't seem to be a Box for the ~A slot of ~A"
	 box-name turtle))

;; used to make sure that we are running the trigger inside of the sprite
;; in order to prevent copies of interface boxes from being active
(defun inside-sprite? (sprite)
  (superior? (static-root) sprite))

;;; These update functions need to do something intelligent even
;;; if they happen to be passed a bad arg

(defun check-and-get-number-arg (box &optional (slot-name-for-bad-arg-warning
                                                'sprite-variable))
  (let ((n (extract-item-from-editor-box box)))
    (cond ((numberp n) n)
          (t (sprite-update-warning
              "Didn't Get a number for ~A. Will change it to ~D"
              slot-name-for-bad-arg-warning 0)
             (values 0 t)))))

;;; +++ interesting fact: compiling this calls genysm no fewer than 40 times (MCL2.0f3c2)
(defsprite-trigger-function bu::update-x-position () (sprite turtle)
  (when (inside-sprite? sprite)
    (let* ((slot (slot-value turtle 'x-position))
	   (box (box-interface-box slot)))
      (if (null box)
          (no-interface-box-error 'X-POSITION turtle)
          (multiple-value-bind (new-x fix?)
              (check-and-get-number-arg box 'X-POSITION�)
            (with-sprites-hidden t
              (move-to turtle new-x (y-position turtle) (not fix?)))))))
  eval::*novalue*)

(add-sprite-update-function x-position bu::update-x-position)


(defsprite-trigger-function bu::update-y-position () (sprite turtle)
  (when (inside-sprite? sprite)
    (let* ((slot (slot-value turtle 'y-position))
	   (box (box-interface-box slot)))
      (if (null box)
          (no-interface-box-error 'Y-POSITION turtle)
          (multiple-value-bind (new-y fix?)
              (check-and-get-number-arg box 'Y-POSITION�)
            (with-sprites-hidden t
              (move-to turtle (x-position turtle) new-y (not fix?)))))))
  eval::*novalue*)

(add-sprite-update-function y-position bu::update-y-position)


(defsprite-trigger-function bu::update-heading () (sprite turtle)
  (when (inside-sprite? sprite)
    (let* ((slot (slot-value turtle 'heading))
	   (box (box-interface-box slot)))
      (if (null box)
          (no-interface-box-error 'HEADING turtle)
          (multiple-value-bind (new-h fix?)
              (check-and-get-number-arg box 'HEADING)
            (with-sprites-hidden nil (turn-to turtle new-h (not fix?)))))))
  eval::*novalue*)

(add-sprite-update-function heading bu::update-heading)

(defun check-and-get-hide-arg (box slot)
  (let ((arg (extract-item-from-editor-box box)))
    (case arg
      ((bu::all bu::true) t)
      ((bu::none bu::false) nil)
      ((bu::subsprites) :subsprites)
      ((bu::no-subsprites) ':no-subsprites)
      (t (sprite-update-warning
          "Bad Value for ~A.  Will change it to ~A"
          'SHOWN? (box-interface-value slot))
         (values (box-interface-value slot) t)))))

(defsprite-trigger-function bu::update-shown? () (sprite turtle)
  (when (inside-sprite? sprite)
    (let* ((slot (slot-value turtle 'shown?))
	   (box (box-interface-box slot)))
      (if (null box)
	  (no-interface-box-error "SHOWN?" turtle)
          (multiple-value-bind (new-shown? fix?)
	      (check-and-get-hide-arg box slot)
            (set-shown? turtle new-shown? (not fix?))))))
  eval::*novalue*)

(add-sprite-update-function shown? bu::update-shown?)

(defun check-and-get-pen-arg (box)
  (let ((pen (extract-item-from-editor-box box)))
    (case pen
      (bu::down 'down)
      (bu::up 'up)
      (bu::erase 'erase)
      ((bu::xor bu::reverse) 'xor)
      (t (sprite-update-warning "Bad Pen Mode,~S, Changing Pen to DOWN" pen)
         (values 'down t)))))

(defsprite-trigger-function bu::update-pen () (sprite turtle)
  (when (inside-sprite? sprite)
    (let* ((slot (slot-value turtle 'pen))
           (box (box-interface-box slot)))
      (if (null box)
        (no-interface-box-error 'PEN turtle)
        (multiple-value-bind (pen fix?) (check-and-get-pen-arg box)
          (set-pen turtle pen (not fix?))))))
  eval::*novalue*)

(add-sprite-update-function pen bu::update-pen)

(defun check-and-get-pen-width-arg (box)
  (let ((arg (extract-item-from-editor-box box))
	(oldarg nil))
    (cond ((and (integerp arg) (> arg 0)) arg)
          ((numberp arg)
           (setq oldarg arg arg (max& 1 (round arg)))
           (sprite-update-warning
            "Pen Width, ~A, should be an integer > 0, changing to ~D"
            oldarg arg)
           (values arg t))
          (t
           (sprite-update-warning "Bad Pen Width,~D, changing to 1" arg)
           (values 1 t)))))

(defsprite-trigger-function bu::update-pen-width () (sprite turtle)
  (when (inside-sprite? sprite)
    (let* ((slot (slot-value turtle 'pen-width))
	   (box (box-interface-box slot)))
      (if (null box)
	  (no-interface-box-error 'pen-width turtle)
          (multiple-value-bind (new-pen-width fix?)
	      (check-and-get-pen-width-arg box)
            (set-pen-width turtle new-pen-width (not fix?))))))
  eval::*novalue*)

(add-sprite-update-function pen-width bu::update-pen-width)

#-mcl
(defun check-and-get-type-font-arg (box)
  (let ((arg (extract-item-from-editor-box box)))
    (cond ((and (integerp arg) (<=& 1 arg 7)) arg)
          (t
           (sprite-update-warning "Bad Pen Font,~D, changing to 4" arg)
           (values 4 t)))))

#+mcl
(defun check-and-get-type-font-arg (box)
  (let ((arg (font-from-box box t)))
    (cond ((integerp arg) arg)
          (t
           (sprite-update-warning "Bad Pen Font,~D, changing to Courier 10 bold" arg)
           (values (make-boxer-font '("Courier" 10 :bold)) t)))))

(defsprite-trigger-function bu::update-type-font () (sprite turtle)
  (when (inside-sprite? sprite)
    (let* ((slot (slot-value turtle 'type-font))
	   (box (box-interface-box slot)))
      (if (null box)
	  (no-interface-box-error 'type-font turtle)
          (multiple-value-bind (new-type-font fix?)
              (check-and-get-type-font-arg box)
            (set-type-font turtle new-type-font (not fix?))))))
  eval::*novalue*)

(add-sprite-update-function type-font bu::update-type-font)


;; this must also act like the bu::update-color-box trigger

(defboxer-primitive bu::update-pen-color ()
  (update-color-box-internal (get-graphics-box)) ; Should return the right box
  (with-sprite-primitive-environment (sprite turtle t)
    (when (inside-sprite? sprite)
      (let* ((slot (slot-value turtle 'pen-color))
	     (box (box-interface-box slot)))
        (if (null box)
            (no-interface-box-error 'pen-color turtle)
	    (set-pen-color turtle (graphics-sheet-background
				   (graphics-sheet box)) t))
        eval::*novalue*))))

(add-sprite-update-function pen-color bu::update-pen-color)

(defun check-and-get-size-arg (box)
  (let ((n (extract-item-from-editor-box box)))
    (cond ((and (numberp n) (plusp n)) n)
          (t (sprite-update-warning
              "Didn't Get a Positive Number for ~A. Changing to ~D" 'SPRITE-SIZE 1)
             (values 1 t)))))

(defsprite-trigger-function bu::update-sprite-size () (sprite turtle)
  (when (inside-sprite? sprite)
    (let* ((slot (slot-value turtle 'sprite-size))
	   (box (box-interface-box slot)))
      (if (null box)
	  (no-interface-box-error 'SPRITE-SIZE turtle)
          (multiple-value-bind (new-size fix?)
	      (check-and-get-size-arg box)
            (with-sprites-hidden nil
              (set-sprite-size turtle new-size (not fix?)))))))
  eval::*novalue*)

(add-sprite-update-function sprite-size bu::update-sprite-size)

(defun check-and-get-number-args (box)
  (let ((n (subseq (flat-box-items box) 0 2)))
    (cond ((every #'numberp n) n)
          (t (sprite-update-warning
              "Didn't Get numbers for ~A. Will change it to ~A"
              'HOME-POSITION '(0 0))
             (values '(0 0) t)))))

(defsprite-trigger-function bu::update-home-position () (sprite turtle)
  (when (inside-sprite? sprite)
    (let* ((slot (slot-value turtle 'home-position))
	   (box (box-interface-box slot)))
      (if (null box)
          (no-interface-box-error 'HOME-POSITION turtle)
	  (multiple-value-bind (new-home fix?)
              (check-and-get-number-args box)
            (set-home-position turtle (car new-home) (cadr new-home)
                               (not fix?))))))
  eval::*novalue*)

(add-sprite-update-function home-position bu::update-home-position)


;;; bu::update-shape should go here, but alas it is in
;;; recursive-prims.lisp

;;; this is for people who change their mind after using change shape
;;; perhaps eval::boxer-toplevel-set-nocache is more appropriate ??

;;; this is a redisplay init because it depends on *default-turtle-shape*
;;; which is also a redisplay init

(def-redisplay-initialization ; :bu-turtle-shape
    (eval::boxer-toplevel-set
     'bu::turtle-shape
     (let ((box (make-box (convert-graphics-list-to-make-box-format
			   *default-turtle-shape*)))
	   ;; a bootstrapping hack, needed because the value of this
	   ;; variable isn't setup until the evaluator inits which
	   ;; (can) comes later.
	   (%learning-shape-graphics-list nil))
       (shape-box-updater-internal box *default-turtle-shape*)
       box))
    )

