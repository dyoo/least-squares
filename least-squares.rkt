#lang racket/base
(require racket/sequence
         racket/match)

;; The Method of Least Squares.
;;
;; Given a set of points (x1, y1), (x2, y2), ... (xn, yn), we want to find 
;; the slope `b` and y-intersect `a` that the line y = a + bx best approximates the
;; points.

(provide least-squares
         least-squares-function)
  
(define (sqr x) (* x x))

;; least-squares: (sequenceof (sequence number number)) -> (values [slope number] [intersect number])
(define (least-squares points)
  (define-values (xs ys) (split-xs-ys points))
  (define n (length xs))
  
  (define slope (/ (- (* n (sum (map * xs ys)))
                      (* (sum xs) (sum ys)))
                   (- (* n (sum (map sqr xs)))
                      (sum (map sqr ys)))))

  (define intersect (- (/ (sum ys) n)
                       (* slope (/ (sum xs) n))))
  
  (values slope intersect))

(define (least-squares-function points)
  (define-values (slope intersect)
    (least-squares points))
  (lambda (x)
    (+ (* x slope) intersect)))


(define (split-xs-ys points)
  (define-values (xs ys)
    (for/fold ([xs '()]
               [ys '()])
              ([p points])
      (match (sequence->list p)
        [(list x y)
         (values (cons x xs) (cons y ys))])))
  (values (reverse xs) (reverse ys)))


(define (sum nums)
  (apply + nums))