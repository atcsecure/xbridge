(define-module (p2p server)
  #:use-module (p2p network)
  #:use-module (p2p query)
  #:use-module (p2p files))

(define (get-requirements cmd)
  (list (get-space-requirements cmd)
        (get-bandwidth-requierment cmd)
        (get-ping-requirement cmd)))

(define (handle-search-node cmd)
  (p2p-query-nodes (get-requirements cmd)))

(define (handle-upload-file cmd)
  (write-file (get-output cmd) (p2p-upload-file (get-node cmd) (get-input cmd))))

(define (handle-download-file cmd)
  (write-file (get-output cmd) (p2p-download-file (get-dfile cmd))))

(define (message-loop)
  (define cmd (get-command))
  (if (not (null? cmd))
      (respond (get-client cmd) 
               (case (type cmd)
                 ("searchnode" (handle-search-node cmd))
                 ("uload" (handle-upload-file cmd))
                 ("dload" (handle-download-file cmd)))))
  (p2p-update-network)
  (message-loop))

(define-public (run-server opts)
  (p2p-join-network)
  (message-loop)
  (p2p-leave-network))
