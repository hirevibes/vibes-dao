;; title: vde005-council
(impl-trait .extension-trait.extension-trait)

(define-constant err-unauthorised (err u3000))
(define-constant err-not-council-member (err u3001))
(define-constant err-proposal-not-found (err u3002))
(define-constant err-funds-already-unlocked (err u3003))

(define-constant council-address (as-contract tx-sender))


(define-map proposal-funds { proposal: principal } { amount: uint, proposer: principal, paid: bool })

(define-map council-members principal bool)
(define-map council-approvals {proposal: principal, team-member: principal} bool)
(define-map council-approval-count principal uint)

(define-data-var council-approvals-required uint u1) ;; approvals required to unlock the funds.

;; --- Authorisation check

(define-public (is-dao-or-extension)
	(ok (asserts! (or (is-eq tx-sender .vibeDAO) (contract-call? .vibeDAO is-extension contract-caller)) err-unauthorised))
)

;; --- Internal DAO functions

(define-public (set-council-member (who principal) (member bool))
	(begin
		(try! (is-dao-or-extension))
		(ok (map-set council-members who member))
	)
)

(define-public (set-approvals-required (new-requirement uint))
	(begin
		(try! (is-dao-or-extension))
		(ok (var-set council-approvals-required new-requirement))
	)
)

(define-public (lock-funds (proposal-address principal) (amount uint) (proposer principal)) 
    (begin
        (try! (is-dao-or-extension))
        (try! (contract-call? .vde000-treasury stx-transfer amount council-address none) )
        (map-insert proposal-funds {proposal: proposal-address} {amount: amount, proposer: proposer, paid: false})
        (ok true)
    )
)

;; --- Public functions
(define-read-only (is-council-member (who principal))
	(default-to false (map-get? council-members who))
)

(define-read-only (has-approved (proposal principal) (who principal))
	(default-to false (map-get? council-approvals {proposal: proposal, team-member: who}))
)

(define-read-only (get-approvals-required)
	(var-get council-approvals-required)
)

(define-read-only (get-approvals (proposal principal))
	(default-to u0 (map-get? council-approval-count proposal))
)

(define-public (unlock-funds (proposal-address principal)) 
   (let
		(
            (data (unwrap! (map-get? proposal-funds {proposal: proposal-address}) err-proposal-not-found))
			(signals (+ (get-approvals proposal-address) (if (has-approved proposal-address tx-sender) u0 u1)))
		)
		(asserts! (is-council-member tx-sender) err-not-council-member)
		(asserts! (is-eq (get paid data) false) err-funds-already-unlocked)

		(and (>= signals (var-get council-approvals-required))
			(map-set proposal-funds {proposal: proposal-address} 
				(merge data {paid: true})
			)
			(try! (as-contract (stx-transfer? (get amount data) tx-sender (get proposer data))))
		)
		(map-set council-approvals {proposal: proposal-address, team-member: tx-sender} true)
		(map-set council-approval-count proposal-address signals)
		(ok signals)
	)
)

;; --- Extension callback

(define-public (callback (sender principal) (memo (buff 34)))
	(ok true)
)


(set-council-member tx-sender true)