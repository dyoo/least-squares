#lang racket/base
(require ;;racket/sequence 
         lang/posn)

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

(define (least-squares points)
  (-least-squares 'least-squares points))

;; least-squares: symbol (sequenceof (sequence number number)) -> (values [slope number] [intersect number])
(define (-least-squares who points)
  (define-values (xs ys) (split-xs-ys who points))
  (define n (length xs))
  (when (< n 2)
    (raise-type-error who "sequence of at least two points" points))
  
  (define xs-sum (sum xs))
  (define ys-sum (sum ys))
  
  (define slope (/ (- (* n (sum (map * xs ys)))
                      (* xs-sum ys-sum))
                   (- (* n (sum (map sqr xs)))
                      (sqr xs-sum))))

  (define intersect (- (/ ys-sum n)
                       (* slope (/ xs-sum n))))
  
  (values slope intersect))


;; Split up the sequence into (xs..., ys...) lists.
(define (split-xs-ys who points)
  (unless (sequence? points)
    (raise-type-error who "sequence of 2d-points" points))
  (define-values (xs ys)
    (for/fold ([xs '()]
               [ys '()])
              ([p points])
      (define (on-element-error seen-so-far)
        (raise-type-error who "a 2d-point" 
                          p))
      (cond [(sequence? p)
             (define-values (more? next) (sequence-generate p))
             (unless (more?) (on-element-error '()))
             (define x (next))
             (unless (more?) (on-element-error (list x)))
             (define y (next))
             (when (more?) (on-element-error (list x y)))
             (values (cons x xs) (cons y ys))]

            [(posn? p)
             (values (cons (posn-x p) xs) 
                     (cons (posn-y p) ys))]
            
            [else
             (on-element-error '())])))
  (values (reverse xs) (reverse ys)))


(define (sum nums)
  (apply + nums))


(struct least-squares-function (slope intersect)
  #:transparent
  #:property prop:procedure (lambda (an-ls x)
                              (+ (* x (least-squares-function-slope an-ls))
                                 (least-squares-function-intersect an-ls))))

(define (new-least-squares-function points)
  (define-values (slope intersect) (-least-squares 'least-squares-function points))
  (least-squares-function slope intersect))
