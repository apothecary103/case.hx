;;; String to string case conversion. No editor dependencies.

(provide camel-case
         pascal-case
         snake-case
         kebab-case
         constant-case
         title-case
         sentence-case)

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

;; Peel off leading whitespace, returning (reversed-whitespace . rest).
(define (span-whitespace cs)
  (let loop ([cs cs] [acc '()])
    (if (and (pair? cs) (char-whitespace? (car cs)))
        (loop (cdr cs) (cons (car cs) acc))
        (cons acc cs))))

;; Convert each line while preserving its indentation and trailing whitespace.
(define (per-line join)
  (define (convert-line line)
    (define lead (span-whitespace (string->list line)))
    ;; Reversed, the trailing padding is a leading one.
    (define tail (span-whitespace (reverse (cdr lead))))
    (string-append (list->string (reverse (car lead)))
                   (join (words (reverse (cdr tail))))
                   (list->string (car tail))))
  (lambda (s) (string-join (map convert-line (split-many s "\n")) "\n")))

(define (delimited sep fold)
  (lambda (ws) (string-join (map fold ws) sep)))

(define snake-case (per-line (delimited "_" string-downcase)))
(define kebab-case (per-line (delimited "-" string-downcase)))
(define constant-case (per-line (delimited "_" string-upcase)))
(define title-case (per-line (delimited " " capitalize)))
(define pascal-case (per-line (lambda (ws) (apply string-append (map capitalize ws)))))

(define camel-case
  (per-line (lambda (ws)
              (if (null? ws)
                  ""
                  (apply string-append
                         (cons (string-downcase (car ws)) (map capitalize (cdr ws))))))))

(define sentence-case
  (per-line (lambda (ws)
              (if (null? ws)
                  ""
                  (string-join (cons (capitalize (car ws)) (map string-downcase (cdr ws)))
                               " ")))))
