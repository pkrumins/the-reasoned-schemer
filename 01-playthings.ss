;
; Chapter 1 of The Reasoned Schemer:
; Playthings
;
; Code examples assembled by Peteris Krumins (peter@catonmat.net).
; His blog is at http://www.catonmat.net  --  good coders code, great reuse.
;
; Get yourself this wonderful book at Amazon: http://bit.ly/89tulL
;
 
; 
; You'll have to get Oleg Kiselyov's implementation of this logic programming
; system to run the examples in this file. The implementation is here:
; http://sourceforge.net/projects/kanren/
;

(load "mk.scm")
(load "mkextraforms.scm")

(define U fail)
(define S succeed)

; ---------------------------------------------------------------------------

; Expression (run* (q) g ...) has the value '() if goals `g ...` fail.
; Goal U (#u) fails.
;
(run* (q) U)                ; '()

; If the variable q is fresh, (== #t q) succeeds associating #t with q.
; == is called the unify operator.
; Variable q is fresh here.
;
(run* (q)
  (== #t q))                ; '(#t)

; Goal U fails.
;
(run* (q)
  U
  (== #t q))                ; '()

; Goals S and (== #s q) succeed, therefore q gets associated with #t.
;
(run* (q)
  S
  (== #t q))                ; '(#t)

; S and (== 'corn q) succeeds, therefore 'corn gets associated 
; with the fresh variable q.
;
(run* (q)
  S
  (== 'corn q))             ; '(corn)

; U fails, therefore the value of (run* ...) is '()
;
(run* (q)
  U
  (== 'corn q))             ; '()

; S succeeds and (== #f q) associates #f with q.
; (run* ...) returns a nonempty list if its goals succeed.
;
(run* (q)
  S
  (== #f q))                ; '(#f)

; (== #f x) fails because x is #t and #f is not equal to #t
;
(run* (q)
  (let ((x #t))
    (== #f x)))             ; '()

; (== #f x) succeeds because x is #f and #f is equal to #f
;
(run* (q)
  (let ((x #f))
    (== #f x)))             ; '(._0)

; (fresh (x ...) g ...) introduces fresh variables `x ...` and succeeds
; if goals `g ...` succeed.
;
(run* (q)
  (fresh (x)
    (== #t x)
    (== #t q)))             ; '(#t)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;                                                                            ;
; The law of fresh:                                                          ;
;                                                                            ;
; If x is fresh, then (== v x) succeeds and associates x with v.             ;
;                                                                            ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; (== #t x) is the same as (== x #t)
;
(run* (q)
  (fresh (x)
    (== x #t)
    (== #t q)))             ; '(#t)

; (== #t q) is the same as (== q #t)
;
(run* (q)
  (fresh (x)
    (== x #t)
    (== q #t)))             ; '(#t)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;                                                                            ;
; The law of ==:                                                             ;
;                                                                            ;
; (== v w) is the same as (== w v).                                          ;
;                                                                            ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; q stays fresh after running, gets reified.
;
(run* (q)
  S)                        ; '(._0)

; x in (run* (x) ...) stays fresh, gets reified.
; Only the (fresh (x) ...)'s x gets associated with #t (different scope).
;
(run* (x)
  (let ((x #f))
    (fresh (x)
      (== #t x))))          ; '(._0)

; Fresh variables (x y) get associated with r. They get reified.
;
(run* (r)
  (fresh (x y)
    (== (cons x (cons y '())) r)))  ; ((._0 ._1))

; Same as previous, only x now is t and y is u.
;
(run* (s)
  (fresh (t u)
    (== (cons t (cons u '())) s)))  ; ((._0 ._1))

; (y x y) get reified.
;
(run* (r)
  (fresh (x)
    (let ((y x))
      (fresh (x)
        (== (cons y (cons x (cons y '()))) r)))))
; ==> '((_.o _.1 _.0))


; (x y x) get reified. Reifying r's value reifies the fresh variables
; in order in which they appear in the list.
;
(run* (r)
  (fresh (x)
    (let ((y x))
      (fresh (x)
        (== (cons x (cons y (cons x '()))) r)))))
; ==> '((_.o _.1 _.0))

; The first goal (== #f q) succeeds, associating #f with q.
; #t can't then be associated with q in the next goal (== #t q), since
; q is no longer fresh.
;
(run* (q)
  (== #f q)
  (== #t q))                ; '()

; Succeeds because in the second goal #f is already associated with q.
;
(run* (q)
  (== #f q)
  (== #f q))                ; '(#f)

; x and q are the same.
;
(run* (q)
  (let ((x q))
    (== #t x)))             ; '(#t)

; r stays fresh. We say x and r co-refer or share.
;
(run* (r)
  (fresh (x)
    (== x r)))              ; '(._0)

; q gets x's association and x got associated with #t before.
;
(run* (q)
  (fresh (x)
    (== #t x)
    (== x q)))              ; '(#t)

; x and q co-refer, then x gets associated with #t that makes q associated
; with #t.
(run* (q)
  (fresh (x)
    (== x q)
    (== #t x)))             ; '(#t)

; x and q are different variables
;
(run* (q)
  (fresh (x)
    (== (eq? x q) q)))      ; '(#f)

; x and q are different variables
;
(run* (q)
  (let ((x q))
    (fresh (q)
      (== (eq? x q) x))))   ; '(#f)

; Remember cond from The Little Schemer?
;
(cond
  (#f #t)
  (else #f))                ; #f

; Remember cond from The Little Schemer?
;
(cond
  (#f S)
  (else U))                 ; fails

; conde is the default control mechanism of Prolog.
; e stands for "every line".
;
(run* (x)
  (conde
    ((== 'olive x) S)
    ((== 'oil x) S)
    (else U)))              ; '(olive oil)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;                                                                            ;
; The law of conde:                                                          ;
;                                                                            ;
; To get more values from conde, pretend that the successful conde line has  ;
; failed, refreshing all variables that got an association from that line.   ;
;                                                                            ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; run1 produces at most one value.
;
(run 1 (x)
  (conde
    ((== 'olive x) S)
    ((== 'oil x) S)
    (else U)))              ; '(olive)

; (S S) leaves x fresh as x was refreshed on the previous line.
;
(run* (x)
  (conde
    ((== 'virgin x) U)
    ((== 'olive x) S)
    (S S)
    ((== 'oil x) S)
    (else U)))              ; '(olive ._0 oil)

; Had we run (run* (x) ...), we'd have gotten '(extra olive oil).
;
(run 2 (x)
  (conde
    ((== 'extra x) S)
    ((== 'virgin x) U)
    ((== 'olive x) S)
    ((== 'oil x) S)
    (else U)))              ; '(extra olive)

; We already knew that.
;
(run* (r)
  (fresh (x y)
    (== 'split x)
    (== 'pea y)
    (== (cons x (cons y '())) r)))      ; '((split pea))

; Didn't know this, but you'll have to figure it out.
;
(run* (r)
  (fresh (x y)
    (conde
      ((== 'split x) (== 'pea y))
      ((== 'navy x) (== 'bean y))
      (else U))
    (== (cons x (cons y '())) r)))      ; '((split pea) (navy bean))

; This is interesting.
;
(run* (r)
  (fresh (x y)
    (conde
      ((== 'split x) (== 'pea y))
      ((== 'navy x) (== 'bean y))
      (else U))
    (== (cons x (cons y (cons 'soup '()))) r)))
; ==> '((split pea soup) (navy bean soup))

; A tea cup
;
(define teacupo
  (lambda (x)
    (conde
      ((== 'tea x) S)
      ((== 'cup x) S)
      (else U))))

; Let's test out the tea cup
;
(run* (x)
  (teacupo x))              ; '(tea cup)

; This is difficult.
;
(run* (r)
  (fresh (x y)
    (conde
      ((teacupo x) (== #t y) S)
      ((== #f x) (== #t y))
      (else U))
    (== (cons x (cons y '())) r)))
; ==> '((tea #t) (cup #t) (#f #t))

; Food for thought.
;
(run* (r)
  (fresh (x y z)
    (conde
      ((== y x) (fresh (x) (== z x)))
      ((fresh (x) (== y x)) (== z x))
      (else U))
    (== (cons y (cons z '())) r)))
; ==> '((._0 ._1) (._0 ._1))

; Shows that the two occurrences of ._0 in the previous example represent
; different variables.
;
(run* (r)
  (fresh (x y z)
    (conde
      ((== y x) (fresh (x) (== z x)))
      ((fresh (x) (== y x)) (== z x))
      (else U))
    (== #f x)
    (== (cons y (cons z '())) r)))
; ==> '((#f ._0) (._0 #f))

; I am unsure about this. Since the first line of let associates
; #t with q, the second line can't associate #f with q anymore. Not sure
; how it associated and succeeded.
;
(run* (q)
  (let ((a (== #t q))
        (b (== #f q)))
    b))
; ==> '(#f)

; Also unsure about this for the same reason.
;
(run* (q)
  (let ((a (== #t q))
        (b (fresh (x)
             (== x q)
             (== #f x)))
        (c (conde
             ((== #t q) S)
             (else (== #f q)))))
    b))
; ==> '(#f)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;.
;                                                                            ;
;                         This space reserved for                            ;
;                               JAM STAINS!                                  ;
;                                                                            ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;'

;
; Go get yourself this wonderful book and have fun with logic programming!
;
; Shortened URL to the book at Amazon.com: http://bit.ly/89tulL
;
; Sincerely,
; Peteris Krumins
; http://www.catonmat.net
;

