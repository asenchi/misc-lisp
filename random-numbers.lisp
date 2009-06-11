;; Notes on random number generation
;; Email thread http://marc.info/?l=sbcl-devel&m=123643791827789&w=2

;; This prints the same random number 100 times in the tight loop :
(dotimes (n 100) (print (random 100 (make-random-state t))))

;; It seems like (make-random-state t) is no more granular than one second.

;; This will print 100 different numbers but it takes 100 seconds ! :
(dotimes (n 100) (print (random 100 (make-random-state t))) (sleep 1))

;; btw - random number generation in a tight loop works as it should with 
;; clozure and allegro.

;; -Justin

;; p.s. - Also, why does the sleep function only accept seconds and not 
;; milliseconds ? Am I completely missing something here ?

;; Justin Grant <jgrant27@gmail.com> writes:

;; > p.s. - Also, why does the sleep function only accept seconds and not 
;; > milliseconds ? Am I completely missing something here ?
;; >
(sleep 0.001)

;; Justin Grant <jgrant27@gmail.com> writes:

;; > This prints the same random number 100 times in the tight loop :
;; > (dotimes (n 100) (print (random 100 (make-random-state t))))
;; >
;; > It seems like (make-random-state t) is no more granular than one second.

;; Under what circumstances do you want to make many, many distinct
;; random state objects within a very short timespan of each other?

;; > This will print 100 different numbers but it takes 100 seconds ! :
;; > (dotimes (n 100) (print (random 100 (make-random-state t))) (sleep 1))
;; >
;; > btw - random number generation in a tight loop works as it should with 
;; > clozure and allegro.

;; I would express random number generation in a tight loop as
(let ((state (make-random-state t))) ; optional
  (dotimes (n 100)
    (print (random 100 state))))
;; rather than anything which generates random states in the middle of
;; the loop.  If this isn't adequate, perhaps because you have specific
;; needs for your random numbers (say that they be guaranteed generated
;; from some source of entropy, rather than from a PRNG) then you should
;; say so.

;; > p.s. - Also, why does the sleep function only accept seconds and not 
;; > milliseconds ? Am I completely missing something here ?

;; That the seconds argument to sleep is a non-negative REAL not an
;; INTEGER, or more generally, the documentation for the SLEEP function?
;; Try (describe 'sleep) at the REPL.

;; Best,

;; Christophe

;; Thanks for the advice.


;; I'm curious, with sbcl, why does this do what's expected :

(let ((state (make-random-state t))) ; optional
  (dotimes (n 100)
    (print (random 100 state))))

;; but this does not (unless the (sleep 1.0) call is included) ? :

(dotimes (n 100)
  (print (random 100 (make-random-state t))))
;; (this works on clozure and allegro just fine)

;; -Justin

;; Because a RANDOM-STATE object represents a certain state of a
;; pseudo-random number generator; the usual method of interacting with
;; such a generator is to use it to draw multiple random numbers, one
;; after the other.  A good pseudo-random number generator will have
;; sufficient internal state that it is difficult to predict the next
;; number from the generator given the previous numbers (up to some
;; limit: for example, the Mersenne Twister generator used in SBCL has
;; period 2^19937 or so -- which should be enough for now).

;; The RANDOM function uses the state in a RANDOM-STATE object to produce
;; such a pseudo-random number, altering the state of RANDOM-STATE in the
;; process, so that the next call to RANDOM will produce a different
;; number.

;; MAKE-RANDOM-STATE with a T argument generates a new random state which
;; has been "randomly initialized by some means" (quoting from the CLHS
;; page for MAKE-RANDOM-STATE).  In SBCL, the 32-bit seed used to
;; initialize the Mersenne Twister's random state in this case is the low
;; 32 bits of the universal time.  So if you create 100 new random states
;; at exactly the same time (to within one second) you will generate 100
;; identical states; if you then draw one number from each of those
;; states, you will draw the same number 100 times.

;; > (this works on clozure and allegro just fine)

;; That depends on your definition of "just fine".  I ask you again: why
;; are you generating 100 new random-state objects within such a short
;; timeframe?

;; Cheers,

;; Christophe

;; justin Grant wrote, On 8/3/09 1:14 PM:
;; > I'm simulating lots of dice being rolled. The results are being used for 
;; > a solving algorithm I'm implementing for a game.

;; The Mersenne Twister is supposed to produce a stream of uncorrelated
;; numbers. For any one simulation you should be able to create just one
;; random-state object for the simulation and use it for all the dice, and
;; different dice will not be correlated.

;; If you want to be able to reproduce a run exactly you can use print to
;; output the value of the random-state object and read to recreate it.
