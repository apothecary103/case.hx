;;; String to string case conversion. No editor dependencies.

;; Digits, punctuation and uncased scripts answer #false to both.
(define (upper? c)
  (not (char=? c (char-downcase c))))
(define (lower? c)
  (not (char=? c (char-upcase c))))

;; Anything else, including `.`, `,` and digits, stays inside a word.
(define (delimiter? c)
  (or (char-whitespace? c) (char=? c #\_) (char=? c #\-)))

;; fooBar -> ("foo" "Bar"), HTTPServer -> ("HTTP" "Server")
(define (words chars)
  ;; `word` accumulates in reverse, so (car word) is the preceding character.
  (let loop ([cs chars] [word '()] [acc '()])
    (define (flush)
      (if (null? word) acc (cons (list->string (reverse word)) acc)))
    (cond
      [(null? cs) (reverse (flush))]
      [(delimiter? (car cs)) (loop (cdr cs) '() (flush))]
      [(and (pair? word)
            (upper? (car cs))
            (or (not (upper? (car word)))
                (and (pair? (cdr cs)) (lower? (car (cdr cs))))))
       (loop (cdr cs) (list (car cs)) (flush))]
      [else (loop (cdr cs) (cons (car cs) word) acc)])))

(define (capitalize w)
  (string-append (string (char-upcase (string-ref w 0)))
                 (string-downcase (substring w 1 (string-length w)))))
