(define-module (p2p network)
  #:use-module (coin rpc))

(define (send-message node message)
  (define soc (socket PF_INET SOCK_STREAM 0)) 
  (connect soc AF_INET
           (inet-pton AF_INET (node-address node))
           (node-port node))
  (write message soc)
  (let ((res (read soc)))
    (close soc)
    res))

(define (make-node id coin-address ip port)
  (list id coin-address ip port))

(define my-node '())

(define (intialize-my-node)
  (define nat-result (punch-through-nat))
  (set! my-node (make-node (generate-node-id) (coin-make-address) (car nat-result) (cdr nat-result))))

(define (my-peers)
  (node-peers my-node))
(define (my-id)
  (node-id my-node))

(define (node-notify-join node)
  (send-message node (list 'join my-node)))

(define (node-notify-leave node)
  (send-message node (list 'leave my-node)))

(define (node-space node)
  (send-message node 'space))
(define (node-ping node)
  (time send-message node 'ping))
(define (node-bandwidth node)
  (send-message node 'bandwidth))
(define (node-id node)
  (car node))
(define (node-peers)
  (send-message node 'get-peers))

(define (upload-file-to-node node key contents)
  (send-message node (list 'upload-file key contents)))
(define (download-file-from-node node key)
  (define price (send-message node 'get-price))
  (pay-node-for-download (node-coin-address node) price)
  (send-message node (list 'download-file key)))

(define (find-node-by-id id)
  (define the-peer (car (my-peers)))
  (if (equals? key (my-id))
      id
      (send-message the-peer (list 'find-node-by-id id))))
