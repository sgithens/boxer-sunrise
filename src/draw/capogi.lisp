;; -*- Mode:LISP; Syntax:Common-Lisp; Package:BOXER-WINDOW; -*-
#|


     Additional Portions Copyright 2014 PyxiSystems LLC


                                      +-Data--+
             This file is part of the | BOXER | system
                                      +-------+


 Caching font glyph bitmaps

There are 4 layers of representation of characters
1) capi - draw-character onto a capi:output-pane and utilities to read the pixels from it
2) internal interchange layer - ogl-char structures and arrays of them to make a font
                               no explicit OpenGL data structures although the glyph bitmap
                               data should be in a form acceptable to GLBitmap (either as a
                               foreign byte array or ready for the FLI to convert it)
                               (list of bytes allows for inclusion in dump, ffi array may
                               be needed if persitence bitmap data is required)
                               CAPOGI (CAPI - OpenGL interchange) layer
                               (9/23/13:prefer ffi array to speed up GPU caching, allow both,
                               disksave with lists, switch to FFI when converting to OpenGL)
3) OpenGL layer - interchange layer is converted to an OpenGL display list a la
                  Chapter 8 of the Red Book
4) files - ability to read/write from interchange layer to/from files
           use pieces of boxer fasl dumper to allow for future imbedding of fonts in boxer files


 Capogi fonts interface with boxer as the "Native Font" in the Opengl-font structs

Modification History (most recent at the top)

 4/ 7/14  {save}-capogi-fonts-info, fill-capogi-font-cache can now save info
 4/ 2/14  *white-enuff* set to 2.0s0 after some experimentation
 3/15/14  white-point?, *white-enuff*
 2/15/14  shortened print-capogi-font result
12/10/13  boxer-font-spec->capogi-font, capogi-size-idx
11/09/13  boxer-font-spec->capogi-font now defaults to "Courier New" if no family match
 8/11/13  started file

|#



(in-package :boxer-window)

(defvar *capogi-font-cache* nil) ;an array of arrays of arrays like *font-cache*

;; these are for reverse lookup (fontspec -> capogi font)
(defvar *capogi-font-families* nil)
(defvar *capogi-font-sizes* nil)

(defstruct (capogi-font (:constructor %make-capogi-font)
                        (:print-function print-capogi-font)
                        (:predicate capogi-font?))
  (capi-font nil)) ; can be an instance of a capi font or a list of (family size styles)

(defun print-capogi-font (font stream &optional level)
  (declare (ignore level))
  (let ((f (capogi-font-capi-font font)))
    (format stream "#<CAPOGI-FONT ~A ~D ~{ ~A~}>" (car f) (cadr f) (cddr f))))

;;; file operations

;; setq this when saving
(defvar *capogi-font-directory* nil)

;; core interface,
;; fill-bootstrapped-font-caches calls make-boxer-font to make an OpenGL font with
;; the result of this function as the "native font"
;; look in the cache, then load if needed
;; we assume that all available fonts are either already in the cache as capogi fonts or
;; loadable from files

(defun capogi-fam-idx (fam-name)
  (position fam-name *capogi-font-families* :test #'string-equal))

;; smarter, closest match instead of only exact....
(defun capogi-size-idx (size)
  (let ((sizelength (length *capogi-font-sizes*)))
    (dotimes (i sizelength (values (1-& sizelength) t))
      (let ((csize (svref *capogi-font-sizes* i)))
        (cond ((= csize size) (return i))
              ((> csize size) (return (values i t))))))))

;; should return the default (Courier New, idx = 0) if no match is found
;; should warn when exact match is not found ?
(defun boxer-font-spec->capogi-font (fontspec)
  (let* ((fam-idx (capogi-fam-idx (car fontspec)))
         (fam (if (null fam-idx)
                  (svref *capogi-font-cache* 0)
                (svref *capogi-font-cache* fam-idx))))
    (cond ((null fam) (error "Unable to get capogi font for ~A" fontspec))
          (t (let* ((size-idx (capogi-size-idx (cadr fontspec)))
                    (size (unless (null size-idx) (svref fam size-idx))))
               (cond ((null size) nil)
                     (t (svref size (font-styles-byte (cddr fontspec))))))))))

(defun font-styles-byte (styles)
  (cond ((null styles) 0)
        ((and (member :bold styles) (member :italic styles)) 3)
        ((member :bold styles) 1)
        ((member :italic styles) 2)
        (t 0)))

;;;; not for regular Boxer operations

(defun init-capogi-font-cache ()
  (flet ((make-size-cache ()
           (let* ((sizes (length boxer::*font-sizes*))
                  (size-cache (make-array sizes)))
             (dotimes (i sizes) (setf (aref size-cache i) (make-array 4)))
             size-cache)))
    (let* ((fam-size (length boxer::*font-families*))
           (return-cache (make-array fam-size)))
      (dotimes (j fam-size) (setf (aref return-cache j) (make-size-cache)))
      return-cache)))

;; called during boxer startup, needs to make sure all the capogifonts are loaded
;; Note that they may have already been disksaved
;; should populate the reverse mapping to allow lookup by fontspec
(defun load-capogi-font-cache (&optional verbose?)
  (when (null *capogi-font-cache*)
    (setq *capogi-font-cache* (init-capogi-font-cache)))
  (when (or (null *capogi-font-families*)
            (not (= (length *capogi-font-families*) (length boxer::*font-families*))))
    (setq *capogi-font-families* (make-array (length boxer::*font-families*)
                                             :initial-contents boxer::*font-families*)))
  (when (null *capogi-font-sizes*)
    (setq *capogi-font-sizes* (let* ((l (length boxer::*font-sizes*))(ra (make-array l)))
                                (dotimes (i l) (setf (svref ra i) (svref boxer::*font-sizes* i)))
                                ra)))
  (do* ((i 0 (1+ i))
        (fams boxer::*font-families* (cdr fams))
        (fam (car fams) (car fams)))
       ((null fam))
    (dotimes (j (length boxer::*font-sizes*))
      (let ((size (svref boxer::*font-sizes* j))
            (k 0))
        (dolist (style '(nil (:bold) (:italic) (:bold :italic)))
          (when verbose?
            (format t "~%Loading ~A ~D ~A => (~D,~D,~D)"
                    fam size (if (null style) "" style) i j k))
            (setf (svref (svref (svref *capogi-font-cache* i) j) k)
                              (%make-capogi-font
                :capi-font (list* fam size style)))
          (setq k  (1+ k)))))))

;; returns a list of strings
(defun capogi-fonts-info ()
  "This is used by the show-font-info primitive."
  (let* ((infofilename (merge-pathnames "info.txt" bw::*capogi-font-directory*))
         (return-strings (list (format nil"Active Font directory is ~A" bw::*capogi-font-directory*))))
    (when (probe-file infofilename)
      (with-open-file (s infofilename :direction :input :element-type 'character)
        (loop (let ((line (read-line s nil nil)))
                (cond ((null line) (return return-strings))
                      (t (push line return-strings)))))))))

(eval-when (load)
  (unless (member :capogi *features*) (push :capogi *features*))
  )
