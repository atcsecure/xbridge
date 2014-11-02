(define-module (p2p network))

;; joins the overlay network
(define (p2p-join-network)
  (generate-or-find-node-uuid) ; generates a node UUID or uses the old one
  (find-seed-peer) ; finds the peer from which to get other peers
  (find-closest-peers) ; then finds the peers closest to this for the DHT overlay network
  (for-each-peer (lambda (peer) (notify peer 'start)))) ; notifies the peers of our existence

;; leaves the overlay network
(define (p2p-leave-network)
  (for-each-peer (lambda (peer) (notify peer 'quit)))) ; notifies the peers of us leaving

;; checks for messages from the network and processes them
(define (p2p-update-network)
  (define msg (wait-for-message 5))
  (if (not (null? message))
      (handle-p2p-message message)))

;; queries nodes to find those that meet the specified requirements
(define (p2p-query-nodes requirements)
  (for-each-peer
   (lambda (peer)
     (if (and (>= (peer-space peer) (car requirements))
              (>= (peer-bandwidth peer) (cadr requirements))
              (>= (peer-ping peer) (caddr requirements)))
         (get-node-id peer)))))

;; uploads a file to a given node (selected from the output of p2p-query-nodes)
;; it returns a list containing the DHT key of the content and the encryption key
(define (p2p-upload-file node file)
  (define encryption-key (make-encryption-key))
  ;; encrypts the file contents with the new key
  (define contents (encrypt encryption-key (read-file file)))
  ;; append the encrypted content's hash to the node's key
  (define key (string-append (node-key node) (hash-file contents)))
  ;; upload the file to the node with the given DHT key
  (upload-file-to-node node key contents) 
  (list key encryption-key)) ;; return the DHT key and encryption keys

;; downlods a file from 
(define (p2p-download-file dfile)
  (define l (parse-dfile dfile)) ; parse the file for its DHT key and encryption keys
  (define node (find-node-by-key (string-take-right (car l) 96))) ; finding the node by key
  (define encrypted-contents (download-file-from-node node (car l))) ; download the encrypted file
  (unencrypt (cadr l) encrypted-contents)) ; unencrypt the file and return it
