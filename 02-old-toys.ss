;
; Chapter 2 of The Reasoned Schemer:
; Teaching Old Toys New Tricks
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

; ---------------------------------------------------------------------------

; This is from The Little Schemer
;
(let ((x (lambda (a) a))
      (y 'c))
  (x y))                                    ; 'c

; x and y stay fresh and get reified
;
(run* (r)
  (fresh (y x)
    (== (cons x (cons y '())) r)))          ; '((._0 ._1))

; Same but with different syntax for constructing x y list of freshes
;
(run* (r)
  (fresh (y x)
    (== `(,x ,y) r)))                       ; '((._0 ._1))

; x is v and y is w, v and w are fresh
;
(run* (r)
  (fresh (v w)
    (== (let
          ((x v)
           (y w))
          (cons x (cons y '()))) r)))       ; '((._0 ._1))

; This is from The Little Schemer
;
(car '(grape raisin pear))                  ; 'grape
(car '(a c o r n))                          ; 'a

; caro is car in relational programming. It succeeds if it can (cons a d) to
; produce p.
;
(define caro
  (lambda (p a)
    (fresh (d)
      (== (cons a d) p))))

; Let's try out caro.
;
(run* (r)
  (caro '(a c o r n) r))                    ; '(a) because 'a is car of '(a c o r n)

(run* (r)
  (caro '(a c o r n) 'a)
  (== #t r));                               ; '(#t) because caro succeeds

; caro associates r with x, then assigns 'pear to x, making r equal to 'pear
;
(run* (r)
  (fresh (x y)
    (caro (cons r (cons y '())) x)
    (== 'pear x)))                          ; '(pear)

; This is from The Little Schemer
;
(cons
  (car '(grape raisin pear))
  (car '((a) (b) (c))))                     ; '(grape a)

(run* (r)
  (fresh (x y)
    (caro '(grape raisin pear) x)
    (caro '((a) (b) (c)) y)
    (== (cons x y) r)))                     ; '((grape a))

; This is from The Little Schemer
;
(cdr '(grape raisin pear))                  ; '(raisin pear)
(car (cdr '(a c o r n)))                    ; 'c

; cdro is cdr in relational programming. It succeeds if it can (cons a d) to
; produce p.
;
(define cdro
  (lambda (p d)
    (fresh (a)
      (== (cons a d) p))))

; Let's try out cdro. The process of transforming (car (cdr l)) into
; (cdro l v) and (caro v r) is called unnesting.
;
(run* (r)
  (fresh (v)
    (cdro '(a c o r n) v)
    (caro v r)))                            ; '(c)

; This is from The Little Schemer
;
(cons
  (cdr '(grape raisin pear))
  (car '((a) (b) (c))))                     ; '((grape raisin) a)

; Same with run
;
(run* (r)
  (fresh (x y)
    (cdro '(grape raisin pear) x)
    (caro '((a) (b) (c)) y)
    (== (cons x y) r)))                     ; '(((grape raisin) a))

; This succeeds because '(c o r n) is cdr of '(a c o r n)
;
(run* (q)
  (cdro '(a c o r n) '(c o r n))
  (== #t q))                                ; '(#t)

; cdr of '(c o r n) is '(o r n) and that needs to match `(,x r n). That can
; only happen if x is 'o.
;
(run* (x)
  (cdro '(c o r n) `(,x r n)))              ; '(o)

; cdr of l is '(c o r n), so l must be '(? c o r n).
; car of l is x is ?
; 'a gets assigned to x, making ?='a and l '(a c o r n)
;
(run* (l)
  (fresh (x)
    (cdro l '(c o r n))
    (caro l x)
    (== 'a x)))                             ; '(a c o r n)

; conso!
;
(define conso
  (lambda (a d p)
    (== (cons a d) p)))

; conso is magnificent
;
(run* (l)
  (conso '(a b c) '(d e) l))                ; '((a b c d e))

; x is 'd because we need to find something that prepended to '(a b c) would
; give '(d a b c). The only possibility is that x is 'd.
;
(run* (x)
  (conso x '(a b c) '(d a b c)))            ; '(d)

; `(,y a ,z c) becomes r, so y is 'e, z is 'd and x is 'c.
; Therefore r becomes '(e a d c)
;
(run* (r)
  (fresh (x y z)
    (== `(e a d ,x) r)
    (conso y `(a ,z c) r)))                 ; '((e a d c))

; What value can we associate with x so that `(,x a ,x c) is `(d a ,x c)?
; Clearly it's 'd.
;
(run* (x)
  (conso x `(a ,x c) `(d a ,x c)))          ; '((d))

; Same but different question
;
;
(run* (l)
  (fresh (x)
    (== `(d a ,x c) l)
    (conso x `(a ,x c) l)))                 ; '((d a d c))

; Same but different question
;
;
(run* (l)
  (fresh (x)
    (conso x `(a ,x c) l)
    (== `(d a ,x c) l)))                    ; '((d a d c))

; Great puzzle
;
(run* (l)
  (fresh (d x y w s)
    (conso w '(a n s) s)
    (cdro l s)
    (caro l x)
    (== 'b x)
    (cdro l d)
    (caro d y)
    (== 'e y)))                             ; '((b e a n s))

; This is from The Little Schemer
;
(null? '(grape raisin pear))                ; #f
(null? '())                                 ; #t

; nullo!
;
(define nullo
  (lambda (l)
    (== '() l)))

; Examples of nullo
;
(run* (q)
  (nullo '(grape raisin pear))
  (== #t q))                                ; '() because nullo fails

(run* (q)
  (nullo '())
  (== #t q))                                ; '(#t) because nullo succeeds

; nullo succeeds and associates '() with q
;
(run* (q)
  (nullo q))                                ; '(()) because nullo succeeds

; This is from The Little Schemer
;
(eq? 'pear 'plum)                           ; #f
(eq? 'plum 'plum)                           ; #t

; eqo!
;
(define eqo
  (lambda (x y)
    (== x y)))

; Examples of eqo
;
(run* (q)
  (eqo 'pear 'plum)
  (== #t q))                                ; '() because eqo fails

(run* (q)
  (eqo 'plum 'plum)
  (== #t q))                                ; '(#t) because eqo succeeds

; This is NOT from The Little Schemer
;
(cons 'split 'pea)                          ; `(split . pea)
`(split pea)                                ; `(split . pea)
(pair? `(split . pea))                      ; #t
(pair? `((split) . pea))                    ; #t
(pair? `())                                 ; #f
(pair? `pair)                               ; #f
(pair? `(pear))                             ; #t because it's `(pear . ())
(car `(pear))                               ; 'pear
(cdr `(pear))                               ; '()
(cons `(split) 'pea)                        ; `((split) . pea)

; Now back to The Reasoned Schemer
;
(run* (r)
  (fresh (x y)
    (== (cons x (cons y 'salad)) r)))       ; `(._0 ._1 . salad)

; pairo!
;
(define pairo
  (lambda (p)
    (fresh (a d)
      (conso a d p))))

; Examples of pairo
;
(run* (q)
  (pairo (cons q q))
  (== #t q))                                ; '(#t) because `(q . q) is a pair

(run* (q)
  (pairo '())
  (== #t q))                                ; '() because '() is not a pair

(run* (q)
  (pairo 'pair)
  (== #t q))                                ; '()

; pairo finds that any two variables make up a pair but since they
; stay fresh, run* reifies them.
;
(run* (x)
  (pairo x))                                ; '((._0 ._1))

; pairo finds that anything in place of r makes a pair in (cons r 'pear)
;
(run* (r)
  (pairo (cons r 'pear)))                   ; '(._0)

; caro, cdro, pairo can be defined using conso
;
(define caro
  (lambda (p a)
    (fresh (d)
      (conso a d p))))

(define cdro
  (lambda (p d)
    (fresh (a)
      (conso a d p))))

; (define pairo ...) aleady did above

; Test caro and cdro
;
(run* (l)
  (fresh (d x y w s)
    (conso w '(a n s) s)
    (cdro l s)
    (caro l x)
    (== 'b x)
    (cdro l d)
    (caro d y)
    (== 'e y)))                             ; '((b e a n s))


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;                                                                            ;
;                         This space reserved for                            ;
;                                                                            ;
;                        "Conso  the  Mangificento"                          ;
;                                                                            ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


;
; Go get yourself this wonderful book and have fun with logic programming!
;
; Shortened URL to the book at Amazon.com: http://bit.ly/89tulL
;
; Sincerely,
; Peteris Krumins
; http://www.catonmat.net
;

