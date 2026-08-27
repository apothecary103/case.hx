;;; A Helix plugin for changing keyword case.

(require "convert.scm")

(require (only-in "helix/editor.scm"
                  editor-focus
                  editor->doc-id
                  editor->text))

(require (only-in "helix/static.scm"
                  current-selection-object
                  selection->ranges
                  selection->primary-index
                  set-current-selection-object!
                  set-current-selection-primary-index!
                  push-range-to-selection!
                  replace-selection-with
                  range
                  range->selection
                  range->from
                  range->to
                  range-anchor
                  range-head))

(require-builtin helix/core/text)

(provide switch-to-camel-case
         switch-to-pascal-case
         switch-to-snake-case
         switch-to-kebab-case
         switch-to-constant-case
         switch-to-title-case
         switch-to-sentence-case)

;; Edit ranges back-to-front, then rebuild the selection front-to-back with accumulated length deltas.
(define (transform-selection! convert)
  (define selection (current-selection-object))
  (define rope (editor->text (editor->doc-id (editor-focus))))
  (define edits
    (map (lambda (r)
           (define from (range->from r))
           (define to (range->to r))
           (define old (rope->string (rope->slice rope from to)))
           (list r from to old (convert old)))
         (selection->ranges selection)))

  (define changed
    (filter (lambda (e) (not (string=? (list-ref e 3) (list-ref e 4)))) edits))

  (unless (null? changed)
    (for-each (lambda (e)
                (set-current-selection-object! (range->selection (list-ref e 0)))
                (replace-selection-with (list-ref e 4)))
              (reverse changed))

    ;; Unchanged ranges move too, so walk all of them.
    (define shifted
      (let loop ([es edits] [delta 0] [acc '()])
        (if (null? es)
            (reverse acc)
            (let* ([e (car es)]
                   [r (list-ref e 0)]
                   [old-len (- (list-ref e 2) (list-ref e 1))]
                   [new-len (string-length (list-ref e 4))]
                   [from (+ (list-ref e 1) delta)])
              (loop (cdr es)
                    (+ delta (- new-len old-len))
                    (cons (if (<= (range-anchor r) (range-head r))
                              (range from (+ from new-len))
                              (range (+ from new-len) from))
                          acc))))))

    (set-current-selection-object! (range->selection (car shifted)))
    (for-each push-range-to-selection! (cdr shifted))
    (set-current-selection-primary-index! (selection->primary-index selection))))

;;@doc
;; Switch to camelCase
(define (switch-to-camel-case)
  (transform-selection! camel-case))

;;@doc
;; Switch to PascalCase
(define (switch-to-pascal-case)
  (transform-selection! pascal-case))

;;@doc
;; Switch to snake_case
(define (switch-to-snake-case)
  (transform-selection! snake-case))

;;@doc
;; Switch to kebab-case
(define (switch-to-kebab-case)
  (transform-selection! kebab-case))

;;@doc
;; Switch to CONSTANT_CASE
(define (switch-to-constant-case)
  (transform-selection! constant-case))

;;@doc
;; Switch to Title Case
(define (switch-to-title-case)
  (transform-selection! title-case))

;;@doc
;; Switch to Sentence case
(define (switch-to-sentence-case)
  (transform-selection! sentence-case))
