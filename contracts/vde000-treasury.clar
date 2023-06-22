
(impl-trait .extension-trait.extension-trait)

(define-constant err-unauthorised (err u3000))
(define-constant err-not-token-owner (err u4))

(define-constant treasury-address (as-contract tx-sender))

;; --- Authorisation check

(define-public (is-dao-or-extension)
	(ok (asserts! (or (is-eq tx-sender .vibeDAO) (contract-call? .vibeDAO is-extension contract-caller)) err-unauthorised))
)

;; --- Internal DAO functions

;; governance-token-trait

(define-public (vibe-lock (amount uint) (owner principal))
	(begin
		(try! (is-dao-or-extension))
		(try! (contract-call? 'SP27BB1Y2DGSXZHS7G9YHKTSH6KQ6BD3QG0AN3CR9.vibes-token transfer amount tx-sender treasury-address none))
		(ok true)
	)
)

(define-public (vibe-unlock (amount uint) (owner principal))
	(begin
		(try! (is-dao-or-extension))
		(try! (as-contract (contract-call? 'SP27BB1Y2DGSXZHS7G9YHKTSH6KQ6BD3QG0AN3CR9.vibes-token transfer amount tx-sender owner none)))
		(ok true)
	)
)


;; --- Extension callback

(define-public (callback (sender principal) (memo (buff 34)))
	(ok true)
)