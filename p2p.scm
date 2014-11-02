(define-module (p2p commands)
  #:use-module (p2p network)); find-peers, get-peers, node-notify-join, node-notify-leave, node-space, node-bandwidth, node-ping, upload-file-to-node, download-file-from-node, find-node-by-id

;; iterates all nodes in the network from the closest nodes out, until max-results results are found
(define (iterate-nodes max-results usable?)
  (define (process-nodes results next-nodes)
    (if (>= (length results) max-results)
        results
        (let ((result (usable? (car next-nodes))))
          (if (not (null? result))
              (process-nodes (result . results) (append (cdr next-nodes) (node-peers (car next-nodes))))
              (process-nodes results (append (cdr next-nodes) (my-peers (car next-nodes))))))))
  (process-nodes '() (get-peers)))

;; joins the overlay network
(define-public (join-network)
  (initialize-my-node) ; generates a node UUID or uses the old one
  (find-peers) ; then finds the peers closest to this for the DHT overlay network
  (for-each (lambda (peer) (node-notify-join peer)) (my-peers))) ; notifies the peers of our existence

;; leaves the overlay network
;; we can't necessarily give up our keyspace because there's only one node ID
(define-public (leave-network)
  (for-each (lambda (peer) (node-notify-leave peer)) (my-peers))) ; notifies the peers of us leaving

;; queries nodes to find the closest 16 that meet the specified requirements
(define-public (query-nodes requirements)
  (iterate-nodes 16
   (lambda (peer)
     (if (and (>= (node-space peer) (car requirements))
              (>= (node-bandwidth peer) (cadr requirements))
              (>= (node-ping peer) (caddr requirements)))
         (list (node-id peer) (node-space peer) (node-bandwidth peer) (node-ping peer))))))

;; uploads a file to a given node (selected from the output of p2p-query-nodes)
;; it returns a list containing the DHT key of the content and the encryption key
(define-public (upload-file id file)
  (define encryption-key (make-encryption-key))
  ;; encrypts the file contents with the new key
  (define contents (encrypt encryption-key (read-file file)))
  ;; append the encrypted content's hash to the node's key
  (define file-key (string-append id (hash-file contents)))
  ;; upload the file to the node with the given DHT key
  (upload-file-to-node (find-node-by-id id) file-key contents) 
  (list key encryption-key)) ;; return the DHT key and encryption keys

;; downlods a file from 
(define-public (download-file file-key encryption-key)
  (define node (find-node-by-id (string-take-right file-key 96))) ; finding the node by key
  (define encrypted-contents (download-file-from-node node file-key)) ; download the encrypted file
  (unencrypt encryption-key encrypted-contents)) ; unencrypt the file and return it
