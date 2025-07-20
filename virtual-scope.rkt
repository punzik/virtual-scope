#! /usr/bin/env racket
#lang racket/gui

(require racket/gui/base
         srfi/1
         data/queue)

(define CAPTION "Virtual Scope")        ; Window caption
(define WINDOW-MIN-WIDTH 400)           ; Windows width
(define WINDOW-MIN-HEIGHT 400)          ; Window height
(define POINTS-COUNT 50)                ; Number of points drawn simultaneously
(define COLOR '(0 235 0))               ; Lines color

;;; Static colors
(define BACKGROUND (make-object color% 0 0 0))
(define GRID0_COLOR (make-object color% 70 70 70))
(define GRID1_COLOR (make-object color% 40 40 40))

;;;
;;; Draw scope grid
;;;
(define  (draw-grid canvas
                    #:bars-count (bars-count 10)
                    #:line0-color (color0 (send the-color-database find-color "Gray"))
                    #:line0-width (line0-w 1)
                    #:line0-style (line0-s 'solid)
                    #:line-color (color (send the-color-database find-color "Gray"))
                    #:line-width (line-w 1)
                    #:line-style (line-s 'dot))
  (let* ((width (send canvas get-width))
         (height (send canvas get-height))
         (x-center (round (/ width 2)))
         (y-center (round (/ height 2)))
         (dc (send canvas get-dc)))

    ;; Zero axes
    (send dc set-smoothing 'unsmoothed)
    (send dc set-pen color0 line0-w line0-s)
    (send dc draw-line x-center 0 x-center height)
    (send dc draw-line 0 y-center width y-center)

    ;; Bars
    (let* ((bar-gap (round (min (/ height bars-count) (/ width bars-count)))))
      (send dc set-pen color line-w line-s)

      (for-each
       (lambda (x)
         (send dc draw-line (+ x-center x) 0 (+ x-center x) height)
         (send dc draw-line (- x-center x) 0 (- x-center x) height))
       (iota (floor (/ width bar-gap 2)) bar-gap bar-gap))

      (for-each
       (lambda (y)
         (send dc draw-line 0 (+ y-center y) width (+ y-center y))
         (send dc draw-line 0 (- y-center y) width (- y-center y)))
       (iota (floor (/ height bar-gap 2)) bar-gap bar-gap)))))

;;;
;;; Draw points
;;;
(define (draw-phosphor canvas points
                       #:draw-count (draw-count 10)
                       #:scale (scale 1))
  (let* ((points (reverse (if (> (length points) draw-count) (take points draw-count) points)))
         (points (append (make-list (- draw-count (length points)) (car points)) points))
         (width (send canvas get-width))
         (height (send canvas get-height))
         (x-center (round (/ width 2)))
         (y-center (round (/ height 2)))
         (dc (send canvas get-dc))
         (scale (* scale (min x-center y-center))))
    (for-each
     (lambda (a b n)
       (let ((ax (+ x-center (* (car a) scale)))
             (ay (+ y-center (* (- (cdr a)) scale)))
             (bx (+ x-center (* (car b) scale)))
             (by (+ y-center (* (- (cdr b)) scale)))
             (alpha (/ (+ n 1) draw-count)))
         (send dc set-pen (make-object color% (first COLOR) (second COLOR) (third COLOR) alpha) 2 'solid)
         (send dc draw-line ax ay bx by)))
     (drop points 1)
     (take points (- draw-count 1))
     (iota (- draw-count 1)))))

;;;
;;; MAIN
;;; Usage: virtual-scope.rkt [FILE/FIFO]
;;;
(define (main args)
  (let* ((file (if (null? (cdr args)) #f (second args)))
         (pqueue
          (let ((q (make-queue)))
            (for-each (lambda (x) (enqueue! q '(0 . 0))) (iota POINTS-COUNT))
            q))
         (frame
          (new frame%
               (label CAPTION)
               (min-width WINDOW-MIN-WIDTH)
               (min-height WINDOW-MIN-HEIGHT)
               (width WINDOW-MIN-WIDTH)
               (height WINDOW-MIN-HEIGHT)))
         (canvas
          (new (class canvas% (super-new))
               (parent frame)
               (paint-callback
                (lambda (canvas dc)
                  (draw-grid canvas
                             #:line0-style 'dot
                             #:line-style 'dot
                             #:line0-color GRID0_COLOR
                             #:line-color GRID1_COLOR)
                  (draw-phosphor canvas
                                 (reverse (queue->list pqueue))
                                 #:draw-count POINTS-COUNT))))))

    (send canvas set-canvas-background BACKGROUND)
    (send frame show #t)

    ;; Read pixels data
    (thread (λ ()
              (let ((thunk
                     (lambda ()
                       (let loop ()
                         (let ((s (read-line)))
                           (if (eof-object? s)
                               (loop)
                               (let ((l (string-split s)))
                                 (when (= 2 (length l))
                                   (let* ((x (string->number (list-ref l 0)))
                                          (y (string->number (list-ref l 1))))
                                     (enqueue! pqueue (cons x y))
                                     (dequeue! pqueue)))
                                 (loop))))))))
                (if file
                    (with-input-from-file file thunk)
                    (thunk)))))

    ;; Refresh screen
    (thread (lambda ()
              (let loop ()
                (send canvas refresh)
                (sleep 0.025)
                (loop))))))

;;; Run MAIN
(main (cons "" (vector->list (current-command-line-arguments))))
