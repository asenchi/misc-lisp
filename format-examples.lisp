;; This is a list of format recipes.  Format can be a beast to work
;; with but it's power is godly.

;; Print a comma seperated list
(defun comma-list (lst)
  (format nil "~{~A~#[~:;, ~]~}" lst))

;; Example usage
;> (comma-list '(1 2 3 4))
;"1, 2, 3, 4"

;; An alternative
(defun comma-list (lst)
  (format nil "~{~A~^, ~}" lst))
