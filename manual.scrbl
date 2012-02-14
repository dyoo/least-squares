#lang scribble/manual
@(require planet/scribble
          scribble/eval
          racket/sandbox
          planet/resolver
          (for-label (this-package-in main)))

@(define my-evaluator (make-base-eval))


@title{Least Squares: fitting a line to a sequence of 2d-points}
@author+email["Danny Yoo" "dyoo@hashcollision.org"]

@(defmodule/this-package main)

This is a simple implementation of the least squares method for lines,
described in a standard statistics textbook @cite["larsen2006"].  Given a sequence of
2d-points, this library computes the slope and intersect of a line
that best fits those points.

Here's a quick-and-dirty example that shows how to use this package with
a tool like Racket's @racketmodname[plot] graph-plotting libraries:
@interaction[#:eval my-evaluator
                    (require (planet dyoo/least-squares))
                    (define data '(#(2.745 2.080) #(2.700 2.045) #(2.690 2.050)
                                   #(2.680 2.005) #(2.675 2.035) #(2.670 2.035)
                                   #(2.665 2.020) #(2.660 2.005) #(2.655 2.010)
                                   #(2.655 2.000) #(2.650 2.000) #(2.650 2.005)
                                   #(2.645 2.015) #(2.635 1.990) #(2.630 1.990)
                                   #(2.625 1.995) #(2.625 1.985) #(2.620 1.970)
                                   #(2.615 1.985) #(2.615 1.990) #(2.615 1.995)
                                   #(2.610 1.990) #(2.590 1.975) #(2.590 1.995)
                                   #(2.565 1.955)))
                    (require plot)
                    (plot (list (points data)
                                (function (least-squares-function data))))]


One of the more direct ways to use the library is to get the slope and intersect
with @racket[least-squares]:
@interaction[#:eval my-evaluator
                    (define-values (a-slope an-intersect)
                      (least-squares '((0 -0.2342) (1 1.0001) (2 1.82123) (3 3.1415926))))
                    a-slope
                    an-intersect
]

Another way to use this library is to use
@racket[least-squares-function] to get a procedure whose behavior
computes points on the fitted line:
@interaction[#:eval my-evaluator
                    (define my-linear-function
                      (least-squares-function '((0 -0.2342) (1 1.0001) (2 1.82123) (3 3.1415926))))
                    (my-linear-function 1)
                    (my-linear-function 2)
                    (my-linear-function 314)]


@section{API}

@defproc[(least-squares [data (sequenceof (sequence number number))]) (values [slope number] [intersect number])]{
Computes the slope and intersect for a line that best
fits the points according to the method of least squares.

For example:
@interaction[#:eval my-evaluator
                    (define-values (a-slope an-intersect)
                      (least-squares '((2.718 3.1415926) (1.618 1.414213))))
                    a-slope
                    an-intersect
                    ]
}


@defproc[(least-squares-function [data (sequenceof (sequence number number))]) [f (number -> number)]]{
Constructs a function that fits the given data.
For example:
@interaction[#:eval my-evaluator
                    (define g 
                      (least-squares-function '((2.718 3.1415926) (1.618 1.414213))))
                    (g 0)
                    (g 3)
                    (g 27)]
}

The function returned from @racket[least-squares-function] is actually a structured
value whose slope and intersect can be queried with @racket[least-squares-function-slope] and
@racket[least-squares-function-intersect].
@defproc[(least-squares-function-slope [f least-squares-function?]) number]{}
@defproc[(least-squares-function-intersect [f least-squares-function?]) number]{}
Example:
@interaction[#:eval my-evaluator
                    (define h 
                      (least-squares-function '((2.718 3.1415926) (1.618 1.414213))))
                    (least-squares-function-slope h)
                    (least-squares-function-intersect h)]

@defproc[(least-squares-function? [x any]) boolean]{Returns true if @racket[x] is a function produced by @racket[least-squares-function].
Example:
@interaction[#:eval my-evaluator
                    (least-squares-function? (lambda (x) x))
                    (define k (least-squares-function '((0 0) (1 1))))
                    (least-squares-function? k)]
}

@bibliography[
@bib-entry[#:key "larsen2006"
           #:title "An Introduction to Mathematical Statistics and Its Applications, 4th Edition"
           #:is-book? #t
           #:author "Richard J. Larsen and Morris L. Marx"
           #:date "2006"]
]