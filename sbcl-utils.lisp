; Scheduler using sbcl threads based on get-universal-time

(defun run-later (utime-to-run function)
  (sb-thread:make-thread
   #'(lambda ()
       (sleep (- utime-to-run (get-universal-time)))
       (funcall function))))

