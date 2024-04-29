(impl-trait .extension-trait.extension-trait)
(use-trait proposal-trait .proposal-trait.proposal-trait)

(define-constant err-unauthorised (err u3100))
(define-constant err-not-governance-token (err u3101))
(define-constant err-insufficient-balance (err u3102))
(define-constant err-unknown-parameter (err u3103))
(define-constant err-proposal-minimum-start-delay (err u3104))
(define-constant err-proposal-maximum-start-delay (err u3105))

(define-map parameters (string-ascii 34) uint)

(map-set parameters "propose-factor" u10000) ;; 10000 $VIBES required to propose.
(map-set parameters "proposal-duration" u1008) ;; ~7 days based on a ~10 minute block time.
(map-set parameters "minimum-proposal-start-delay" u144) ;; ~1 day minimum delay before voting on a proposal can start.
(map-set parameters "maximum-proposal-start-delay" u1008) ;; ~7 days maximum delay before voting on a proposal can start.

;; --- Authorisation check

(define-public (is-dao-or-extension)
	(ok (asserts! (or (is-eq tx-sender .vibeDAO) (contract-call? .vibeDAO is-extension contract-caller)) err-unauthorised))
)

;; --- Internal DAO functions

;; Parameters

(define-public (set-parameter (parameter (string-ascii 34)) (value uint))
	(begin
		(try! (is-dao-or-extension))
		(try! (get-parameter parameter))
		(ok (map-set parameters parameter value))
	)
)

(define-private (set-parameters-iter (item {parameter: (string-ascii 34), value: uint}) (previous (response bool uint)))
	(begin
		(try! previous)
		(try! (get-parameter (get parameter item)))
		(ok (map-set parameters (get parameter item) (get value item)))
	)
)

(define-public (set-parameters (parameter-list (list 200 {parameter: (string-ascii 34), value: uint})))
	(begin
		(try! (is-dao-or-extension))
		(fold set-parameters-iter parameter-list (ok true))
	)
)

;; --- Public functions

;; Parameters

(define-read-only (get-parameter (parameter (string-ascii 34)))
	(ok (unwrap! (map-get? parameters parameter) err-unknown-parameter))
)

;; Proposals

(define-public (propose (proposal <proposal-trait>) (start-block-height uint))
	(begin
		(asserts! (>= start-block-height (+ block-height (try! (get-parameter "minimum-proposal-start-delay")))) err-proposal-minimum-start-delay)
		(asserts! (<= start-block-height (+ block-height (try! (get-parameter "maximum-proposal-start-delay")))) err-proposal-maximum-start-delay)
		(asserts! (>= (unwrap-panic (contract-call? 'SP27BB1Y2DGSXZHS7G9YHKTSH6KQ6BD3QG0AN3CR9.vibes-token get-balance tx-sender)) (try! (get-parameter "propose-factor"))) err-insufficient-balance)
		(contract-call? .vde001-proposal-voting add-proposal
			proposal
			{
				start-block-height: start-block-height,
				end-block-height: (+ start-block-height (try! (get-parameter "proposal-duration"))),
				proposer: tx-sender
			}
		)
	)
)

;; --- Extension callback

(define-public (callback (sender principal) (memo (buff 34)))
	(ok true)
)