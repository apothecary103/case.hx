;;; Run with: steel test.scm

(require "convert.scm")

(define failures 0)

(define (check label got want)
  (unless (equal? got want)
    (set! failures (+ failures 1))
    (displayln (list "FAIL" label 'got got 'want want))))

;; input, camel, pascal, snake, kebab, title, sentence, constant
(define table
  (list
   (list "my_variable_name"
         "myVariableName" "MyVariableName" "my_variable_name" "my-variable-name"
         "My Variable Name" "My variable name" "MY_VARIABLE_NAME")
   (list "MyClass"
         "myClass" "MyClass" "my_class" "my-class"
         "My Class" "My class" "MY_CLASS")
   (list "HTTPServer"
         "httpServer" "HttpServer" "http_server" "http-server"
         "Http Server" "Http server" "HTTP_SERVER")
   (list "hello world"
         "helloWorld" "HelloWorld" "hello_world" "hello-world"
         "Hello World" "Hello world" "HELLO_WORLD")
   (list "parse2Json"
         "parse2Json" "Parse2Json" "parse2_json" "parse2-json"
         "Parse2 Json" "Parse2 json" "PARSE2_JSON")
   (list "kebab-case-thing"
         "kebabCaseThing" "KebabCaseThing" "kebab_case_thing" "kebab-case-thing"
         "Kebab Case Thing" "Kebab case thing" "KEBAB_CASE_THING")
   (list "  padded_word  "
         "  paddedWord  " "  PaddedWord  " "  padded_word  " "  padded-word  "
         "  Padded Word  " "  Padded word  " "  PADDED_WORD  ")
   (list "a" "a" "A" "a" "a" "A" "A" "A")
   (list "" "" "" "" "" "" "" "")
   (list "   " "   " "   " "   " "   " "   " "   " "   ")))

(for-each
 (lambda (row)
   (define input (car row))
   (check (list input 'camel) (camel-case input) (list-ref row 1))
   (check (list input 'pascal) (pascal-case input) (list-ref row 2))
   (check (list input 'snake) (snake-case input) (list-ref row 3))
   (check (list input 'kebab) (kebab-case input) (list-ref row 4))
   (check (list input 'title) (title-case input) (list-ref row 5))
   (check (list input 'sentence) (sentence-case input) (list-ref row 6))
   (check (list input 'constant) (constant-case input) (list-ref row 7)))
 table)

(check 'newlines (snake-case "fooBar\n  bazQux\n") "foo_bar\n  baz_qux\n")
(check 'crlf (snake-case "fooBar\r\nbazQux") "foo_bar\r\nbaz_qux")
(check 'blank-line (title-case "a\n\nb") "A\n\nB")
(check 'punctuation (title-case "hello, world!") "Hello, World!")
(check 'dotted (snake-case "foo.bar") "foo.bar")
(check 'trailing-acronym (snake-case "parseURL") "parse_url")
(check 'acronym-only (snake-case "URL") "url")
(check 'from-constant (camel-case "MY_CONST_VALUE") "myConstValue")

(displayln (if (= failures 0) "ok" (list failures "failures")))
