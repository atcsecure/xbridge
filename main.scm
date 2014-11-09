(use-modules
 (p2p server)
 (p2p commands))

(define option-spec
  '((daemonize (single-char #\d) (value #f))
    (version (single-char #\v) (value #f))
    (help (single-char #\h) (value #f))))

(define (get-opt n opts)
  (options-ref opts n (assoc n defaults)))

(define (main args)
  (let ((opts (getopt-long args option-spec #:stop-at-first-non-option #t)))
    (cond
     ((options-ref opts 'daemonize #f) (display-version))
     ((options-ref opts 'help #f) (display-help))
     ((options-ref opts 'daemonize #f) (run-server opts))
     (default (run-command (option-ref opts '() '()))))))
\n;; end main
