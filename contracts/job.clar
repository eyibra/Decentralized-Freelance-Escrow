;; Job Contract
;; Defines project terms and milestones

(define-map jobs
  { id: uint }
  {
    client: principal,
    freelancer: principal,
    title: (string-ascii 64),
    amount: uint,
    status: (string-ascii 10)
  }
)

(define-map milestones
  { job-id: uint, milestone-id: uint }
  {
    description: (string-ascii 64),
    amount: uint,
    completed: bool
  }
)

(define-data-var job-count uint u0)

;; Create a new job
(define-public (create-job (freelancer principal) (title (string-ascii 64)) (amount uint))
  (let
    ((new-id (+ (var-get job-count) u1)))

    ;; Update job counter
    (var-set job-count new-id)

    ;; Create the job
    (ok (map-set jobs
      { id: new-id }
      {
        client: tx-sender,
        freelancer: freelancer,
        title: title,
        amount: amount,
        status: "created"
      }
    ))
  )
)

;; Add a milestone to a job
(define-public (add-milestone (job-id uint) (milestone-id uint) (description (string-ascii 64)) (amount uint))
  (let
    ((job (unwrap! (map-get? jobs { id: job-id }) (err u404))))

    ;; Only client can add milestones
    (asserts! (is-eq tx-sender (get client job)) (err u403))

    ;; Create the milestone
    (ok (map-set milestones
      { job-id: job-id, milestone-id: milestone-id }
      {
        description: description,
        amount: amount,
        completed: false
      }
    ))
  )
)

;; Start the job
(define-public (start-job (job-id uint))
  (let
    ((job (unwrap! (map-get? jobs { id: job-id }) (err u404))))

    ;; Only freelancer can start
    (asserts! (is-eq tx-sender (get freelancer job)) (err u403))

    ;; Update job status
    (ok (map-set jobs
      { id: job-id }
      (merge job { status: "active" })
    ))
  )
)

;; Get job details
(define-read-only (get-job (job-id uint))
  (map-get? jobs { id: job-id })
)

;; Get milestone details
(define-read-only (get-milestone (job-id uint) (milestone-id uint))
  (map-get? milestones { job-id: job-id, milestone-id: milestone-id })
)
