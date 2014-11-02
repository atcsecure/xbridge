(define-module (coin rpc)
  #:use-module (p2p network))

(define (rpc-call . args)
  (define socket (socket PF_INET SOCK_STREAM 0))
  (connect soc AF_INET
           (inet-pton AF_INET (rpc-server-address))
           (rpc-server-port))
  (write (apply string-append args) soc)
  (let ((res (read-json soc)))
    (close soc)
    res))

(define (pay-node-for-download address amount)
  (rpc-call "sendto" address (number->string amount)))

(define (coin-make-address)
  (rpc-call "getnewaddress"))


