
;; these tests are only valid if chibi-scheme is compiled with full
;; numeric support (USE_BIGNUMS, USE_FLONUMS and USE_MATH)

(define *tests-run* 0)
(define *tests-passed* 0)

(define-syntax test
  (syntax-rules ()
    ((test expect expr)
     (begin
       (set! *tests-run* (+ *tests-run* 1))
       (let ((str (call-with-output-string (lambda (out) (display 'expr out))))
             (res expr))
         (display str)
         (write-char #\space)
         (display (make-string (max 0 (- 72 (string-length str))) #\.))
         (flush-output)
         (cond
          ((equal? res expect)
           (set! *tests-passed* (+ *tests-passed* 1))
           (display " [PASS]\n"))
          (else
           (display " [FAIL]\n")
           (display "    expected ") (write expect)
           (display " but got ") (write res) (newline))))))))

(define (test-report)
  (write *tests-passed*)
  (display " out of ")
  (write *tests-run*)
  (display " passed (")
  (write (* (/ *tests-passed* *tests-run*) 100))
  (display "%)")
  (newline))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(define (integer-neighborhoods x)
  (list x (+ 1 x) (+ -1 x) (- x) (- 1 x) (- -1 x)))

(test '(536870912 536870913 536870911 -536870912 -536870911 -536870913)
    (integer-neighborhoods (expt 2 29)))

(test '(1073741824 1073741825 1073741823 -1073741824 -1073741823 -1073741825)
    (integer-neighborhoods (expt 2 30)))

(test '(2147483648 2147483649 2147483647 -2147483648 -2147483647 -2147483649)
    (integer-neighborhoods (expt 2 31)))

(test '(4294967296 4294967297 4294967295 -4294967296 -4294967295 -4294967297)
    (integer-neighborhoods (expt 2 32)))

(test '(4611686018427387904 4611686018427387905 4611686018427387903
        -4611686018427387904 -4611686018427387903 -4611686018427387905)
    (integer-neighborhoods (expt 2 62)))

(test '(9223372036854775808 9223372036854775809 9223372036854775807
        -9223372036854775808 -9223372036854775807 -9223372036854775809)
    (integer-neighborhoods (expt 2 63)))

(test '(18446744073709551616 18446744073709551617 18446744073709551615
        -18446744073709551616 -18446744073709551615 -18446744073709551617)
    (integer-neighborhoods (expt 2 64)))

(test '(85070591730234615865843651857942052864
        85070591730234615865843651857942052865
        85070591730234615865843651857942052863
        -85070591730234615865843651857942052864
        -85070591730234615865843651857942052863
        -85070591730234615865843651857942052865)
    (integer-neighborhoods (expt 2 126)))

(test '(170141183460469231731687303715884105728
        170141183460469231731687303715884105729
        170141183460469231731687303715884105727
        -170141183460469231731687303715884105728
        -170141183460469231731687303715884105727
        -170141183460469231731687303715884105729)
    (integer-neighborhoods (expt 2 127)))

(test '(340282366920938463463374607431768211456
        340282366920938463463374607431768211457
        340282366920938463463374607431768211455
        -340282366920938463463374607431768211456
        -340282366920938463463374607431768211455
        -340282366920938463463374607431768211457)
    (integer-neighborhoods (expt 2 128)))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(define (integer-arithmetic-combinations a b)
  (list (+ a b) (- a b) (* a b) (quotient a b) (remainder a b)))

(define (sign-combinations a b)
  (list (integer-arithmetic-combinations a b)
        (integer-arithmetic-combinations (- a) b)
        (integer-arithmetic-combinations a (- b))
        (integer-arithmetic-combinations (- a) (- b))))

;; fix x fix
(test '((1 -1 0 0 0) (1 -1 0 0 0) (-1 1 0 0 0) (-1 1 0 0 0))
    (sign-combinations 0 1))
(test '((2 0 1 1 0) (0 -2 -1 -1 0) (0 2 -1 -1 0) (-2 0 1 1 0))
    (sign-combinations 1 1))
(test '((59 25 714 2 8) (-25 -59 -714 -2 -8)
        (25 59 -714 -2 8) (-59 -25 714 2 -8))
    (sign-combinations 42 17))

;; fix x big
(test '((4294967338 -4294967254 180388626432 0 42)
        (4294967254 -4294967338 -180388626432 0 -42)
        (-4294967254 4294967338 -180388626432 0 42)
        (-4294967338 4294967254 180388626432 0 -42))
    (sign-combinations 42 (expt 2 32)))

;; big x fix
(test '((4294967338 4294967254 180388626432 102261126 4)
        (-4294967254 -4294967338 -180388626432 -102261126 -4)
        (4294967254 4294967338 -180388626432 -102261126 4)
        (-4294967338 -4294967254 180388626432 102261126 -4))
    (sign-combinations (expt 2 32) 42))

;; big x bigger
(test '((12884901889 -4294967297 36893488151714070528 0 4294967296)
        (4294967297 -12884901889 -36893488151714070528 0 -4294967296)
        (-4294967297 12884901889 -36893488151714070528 0 4294967296)
        (-12884901889 4294967297 36893488151714070528 0 -4294967296))
    (sign-combinations (expt 2 32) (+ 1 (expt 2 33))))

;; bigger x big
(test '((12884901889 4294967297 36893488151714070528 2 1)
        (-4294967297 -12884901889 -36893488151714070528 -2 -1)
        (4294967297 12884901889 -36893488151714070528 -2 1)
        (-12884901889 -4294967297 36893488151714070528 2 -1))
    (sign-combinations (+ 1 (expt 2 33)) (expt 2 32)))

(test-report)