;; Classic interpreter/interpreter.cc: mixed_eval's cond case.
;; Keep children unevaluated: only the first matching answer or fallback runs.
!(add-atom &self (tableRowOperator cond))

(= (cond () $itable $row)
   (Error cond "Expected condition-answer pairs and a fallback"))
(= (cond ($fallback) $itable $row)
   (evalTableRow $fallback $itable $row))
(= (cond (cons $condition (cons $answer $rest)) $itable $row)
   (if (== (evalTableRow $condition $itable $row) True)
       (evalTableRow $answer $itable $row)
       (cond $rest $itable $row)))
