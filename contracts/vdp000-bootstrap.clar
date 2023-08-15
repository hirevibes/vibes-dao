;; VibesDAO using ExecutorDAO framework. 
;; Version: 0.1.0

;; Title: VDP000 Bootstrap
;; Description: This contract is used to bootstrap the VibesDAO.

;; ------------------------------------------------
;; All the principal IDs are for testnet.
;; ------------------------------------------------

(impl-trait .proposal-trait.proposal-trait)

(define-public (execute (sender principal))
	(begin
		;; Enable genesis extensions.
		(try! (contract-call? .vibeDAO set-extensions
			(list
				{extension: .vde000-treasury, enabled: true}
				{extension: .vde001-proposal-voting, enabled: true}
				{extension: .vde002-proposal-submission, enabled: true}
				{extension: .vde003-emergency-proposals, enabled: true}
				{extension: .vde004-emergency-execute, enabled: true}
			)
		))

		;; Set emergency team members.
		(try! (contract-call? .vde003-emergency-proposals set-emergency-team-member 'ST3B5YKP344KCZ5Q8VKA5PNRF3X546PMP80EMWC10 true))
		(try! (contract-call? .vde003-emergency-proposals set-emergency-team-member 'ST7F9EMG5A9BKVBG8N6Q2KD2NQNGXMPB5PQF49Z7  true))

		;; Set executive team members.
		(try! (contract-call? .vde004-emergency-execute set-executive-team-member 'ST3B5YKP344KCZ5Q8VKA5PNRF3X546PMP80EMWC10 true))
		(try! (contract-call? .vde004-emergency-execute set-executive-team-member 'ST7F9EMG5A9BKVBG8N6Q2KD2NQNGXMPB5PQF49Z7 true))
		(try! (contract-call? .vde004-emergency-execute set-executive-team-member 'ST1X29VHGHWYBFDX0DYEN1GH0S719JG9PG7HNY7VG true))
		(try! (contract-call? .vde004-emergency-execute set-executive-team-member 'ST2XTTPFAPSHCPSK905V7C93RBXWFZ4YH8A8FBWV true))
		(try! (contract-call? .vde004-emergency-execute set-signals-required u3)) ;; signal from 3 out of 4 team members requied.

		(try! (contract-call? .vde005-council set-approvals-required u3)) ;; approvals from 3 out of 4 team members requied.


		(print "ExecutorDAO has risen.")
		(ok true)
	)
)