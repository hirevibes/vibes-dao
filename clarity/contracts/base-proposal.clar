;;Title:


;;Brief Summary:


;;Proposal Details:


;;Rationale:


;;Implementation Plan:


;;Timeline:


;;Expected Outcomes:



(impl-trait .proposal-trait.proposal-trait)


(define-public (execute (sender principal))
	(begin
		
        ;; vibes-transfer (initial-amount, receiver, memo)
        (try! (contract-call? .vde000-treasury vibes-transfer u100 'ST3B5YKP344KCZ5Q8VKA5PNRF3X546PMP80EMWC10 none))
		
		;; lock-funds (proposal-address ,amount, receiver/proposer)
		(try! (contract-call? .vde005-council lock-funds (as-contract tx-sender) u900 'ST3B5YKP344KCZ5Q8VKA5PNRF3X546PMP80EMWC10))
		
		(ok true)
	)
)