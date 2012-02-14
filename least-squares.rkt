#lang racket/base
(require racket/sequence
         racket/match)

;; The Method of Least Squares.
;;
;; Given a set of points (x1, y1), (x2, y2), ... (xn, yn), we want to find 
;; the slope `b` and y-intersect `a` that the line y = a + bx best approximates the
;; points.

(provide least-squares
         (rename-out [new-least-squares-function least-squares-function])
         least-squares-function?
         least-squares-function-slope
         least-squares-function-intersect)


(define (sqr x) (* x x))

;; least-squares: (sequenceof (sequence number number)) -> (values [slope number] [intersect number])
(define (least-squares points)
  (define-values (xs ys) (split-xs-ys points))
  (define n (length xs))
  
  (define slope (/ (- (* n (sum (map * xs ys)))
                      (* (sum xs) (sum ys)))
                   (- (* n (sum (map sqr xs)))
                      (sqr (sum xs)))))

  (define intersect (- (/ (sum ys) n)
                       (* slope (/ (sum xs) n))))
  
  (values slope intersect))


(define (split-xs-ys points)
  (define-values (xs ys)
    (for/fold ([xs '()]
               [ys '()])
              ([p points])
      (define pl (sequence->list p))
      (match pl
        [(list x y)
         (values (cons x xs) (cons y ys))]
        [else
         (raise-type-error 'least-squares "expected a sequence of two numbers: ~e" pl)])))
  (values (reverse xs) (reverse ys)))


(define (sum nums)
  (apply + nums))


(struct least-squares-function (slope intersect)
  #:transparent
  #:property prop:procedure (lambda (an-ls x)
                              (+ (* x (least-squares-function-slope an-ls))
                                 (least-squares-function-intersect an-ls))))

(define (new-least-squares-function points)
  (define-values (slope intersect) (least-squares points))
  (least-squares-function slope intersect))
