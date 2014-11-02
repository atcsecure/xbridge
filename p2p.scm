(define-module (p2p network))

(define (p2p-join-network)
  (generate-node-uuid)
  (find-seed-peer)
  (find-closest-peers)
  (for-each-peer (lambda (peer) (notify peer 'start))))

(define (p2p-leave-network)
  (for-each-peer (lambda (peer) (notify peer 'quit))))

(define (p2p-update-network)
  (define msg (wait-for-message 5))
  (if (not (null? message))
      (handle-p2p-message message)))

(define (p2p-query-nodes requirements)
  (for-each-peer
   (lambda (peer)
     (if (and (>= (peer-space peer) (car requirements))
              (>= (peer-bandwidth peer) (cadr requirements))
              (>= (peer-ping peer) (caddr requirements)))
         (get-node-id peer)))))

(define (p2p-upload-file node file)
  (define contents (encrypt (current-encryption-key) (read-file file)))
  (define key (string-append (node-key node) (hash-file contents)))
  (upload-file-to-node node key contents)
  (list key (current-encryption-key)))

(define (p2p-download-file dfile)
  (define l (parse-dfile dfile))
  (define node (find-node-by-key (first l)))
  (define encrypted-contents (download-file-from-node node (car l)))
  (unencrypt (cadr l) encrypted-contents))
