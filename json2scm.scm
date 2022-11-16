(import (chicken process-context)
        (chicken pathname)
        (chicken format)
        medea
        miscmacros)

(define (json-file->sexp filename)
  (with-input-from-file filename read-json))

(define (sexp->file data filename)
  (with-output-to-file filename
    (lambda ()
      (write data))))

(define-syntax-rule (create-module module-name data)
  `(module ,'module-name (data)
           (import scheme)
           (define data ,data)))

(define (replace-extension filename new-extension)
  (string-append (pathname-strip-extension filename) new-extension))

(define (json-file->scm-file json-file)
  (let* ((data (json-file->sexp json-file))
        (mod (create-module sp500 data)))
    (sexp->file mod (replace-extension json-file ".scm"))))

(if (= (length (command-line-arguments)) 1)
    (let* ((json-file (car (command-line-arguments)))
           (scm-file (replace-extension json-file ".scm")))
      (begin
        (json-file->scm-file json-file)
        (display (format "Converted ~A to ~A~%" json-file scm-file))))
    (error "Wrong number of parameters"))
