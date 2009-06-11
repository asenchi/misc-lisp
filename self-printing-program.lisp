;;; File: showself1.lisp

(defvar *src* ";;; File: showself1.lisp

(defvar *src* ~S)

(defun showself1 ()
  (format t *src* *src*))
")

(defun showself1 ()
  (format t *src* *src*) " ")
