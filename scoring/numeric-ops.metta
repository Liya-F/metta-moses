;; Classic combo/interpreter/eval.cc: numeric operators inside predicates.
;; Raw children let operators preserve Classic's evaluation order.
!(add-atom &self (tableRowOperator plus))
!(add-atom &self (tableRowOperator times))
!(add-atom &self (tableRowOperator div))
!(add-atom &self (tableRowOperator log))
!(add-atom &self (tableRowOperator exp))
!(add-atom &self (tableRowOperator sin))
!(add-atom &self (tableRowOperator impulse))
!(add-atom &self (tableRowOperator greater_than_zero))

(= (plus $children $itable $row)
   (if (== $children ())
       plus
       (foldl-atom $children 0.0 $total $child
         (numericStep + $total $child $itable $row))))

(= (times $children $itable $row)
   (if (== $children ())
       times
       (foldl-atom $children 1.0 $total $child
         (if (== $total 0.0)
             $total
             (numericStep * $total $child $itable $row)))))

(= (div ($numerator $denominator) $itable $row)
   (let $left (evalTableRow $numerator $itable $row)
     (case $left
       (((Error $_ $_) $left)
        ($number
          (if (numericZero $number)
              (* 1.0 $number)
              (let $right (evalTableRow $denominator $itable $row)
                (case $right
                  (((Error $_ $_) $right)
                   ($divisor
                     (let $result (numericArithmetic / $number $divisor)
                       (if (isNumericSpecial $result)
                           (Error $result "Numeric overflow")
                           $result))))))))))))

;; ABS_LOG is disabled in Classic combo/vertex.h: use log(x), not log(abs(x)).
(= (log ($child) $itable $row)
   (let $value (evalTableRow $child $itable $row)
     (case $value
       (((Error $_ $_) $value)
        (PositiveInfinity (Error PositiveInfinity "Numeric overflow"))
        (NegativeInfinity (Error NotANumber "Numeric overflow"))
        (NotANumber (Error NotANumber "Numeric overflow"))
        ($number
          (if (<= $number 0.0)
              (Error (if (< $number 0.0) NotANumber NegativeInfinity) "Numeric overflow")
              (numericResult (catch (log-math (exp 1.0) $number)) PositiveInfinity)))))))

(= (exp ($child) $itable $row)
   (let $value (evalTableRow $child $itable $row)
     (case $value
       (((Error $_ $_) $value)
        (PositiveInfinity (Error PositiveInfinity "Numeric overflow"))
        (NegativeInfinity 0.0)
        (NotANumber NotANumber)
        ($number (numericResult (catch (exp $number)) PositiveInfinity))))))

(= (sin ($child) $itable $row)
   (let $value (evalTableRow $child $itable $row)
     (case $value
       (((Error $_ $_) $value)
        (PositiveInfinity NotANumber)
        (NegativeInfinity NotANumber)
        (NotANumber NotANumber)
        ($number (numericResult (catch (sin-math $number)) NotANumber))))))

(= (impulse ($child) $itable $row)
   (let $value (evalTableRow $child $itable $row)
     (case $value
       (((Error $_ $_) $value)
        (True 1.0)
        ($other 0.0)))))

;; Classic catches OverflowException here and tests its carried numeric value.
(= (greater_than_zero ($child) $itable $row)
   (let $value (evalTableRow $child $itable $row)
     (case $value
       (((Error $overflow "Numeric overflow") (== $overflow PositiveInfinity))
        ((Error $_ $_) $value)
        (PositiveInfinity True)
        (NegativeInfinity False)
        (NotANumber False)
        ($number (> $number 0.0))))))

;; Fold raw children; an arithmetic failure skips the remaining evaluations.
(= (numericStep $operator $total $child $itable $row)
   (case $total
     (((Error $_ $_) $total)
      ($number
        (let $value (evalTableRow $child $itable $row)
          (case $value
            (((Error $_ $_) $value)
             ($operand (numericArithmetic $operator $number $operand)))))))))

;; Classic + and * retain IEEE nonfinite results; / converts them into an exception.
;; Keep those categories separate from Error, which stops evaluation.
(= (numericArithmetic $operator $left $right)
   (if (or (isNumericSpecial $left) (isNumericSpecial $right))
       (if (or (== $left NotANumber) (== $right NotANumber))
           NotANumber
           (case $operator
             ((+
                (if (and (isNumericSpecial $left) (isNumericSpecial $right))
                    (if (== $left $right) $left NotANumber)
                    (if (isNumericSpecial $left) $left $right)))
              (*
                (if (or (numericZero $left) (numericZero $right))
                    NotANumber
                    (numericProductSign $left $right)))
              (/
                (if (isNumericSpecial $right)
                    (if (isNumericSpecial $left)
                        NotANumber
                        (if (== (numericProductSign $left $right) NegativeInfinity) -0.0 0.0))
                    (numericProductSign $left $right))))))
       (let* (
          ($leftValue (* 1.0 $left))
          ;; Static native calls preserve exceptions; reduce can turn them into zero solutions.
          ($native (case $operator
                     ((+ (catch (+ $leftValue $right)))
                      (* (catch (* $leftValue $right)))
                      (/ (catch (/ $leftValue $right))))))
          ($result (numericResult $native
                     (if (== $operator +) (numericSign $left)
                         (numericProductSign $left $right)))))
         (case $result
           (((Error $value "Numeric overflow") $value)
            ($value $value))))))

(= (isNumericSpecial $value)
   (once (is-member $value (PositiveInfinity NegativeInfinity NotANumber))))

(= (numericZero $value)
   (if (isNumericSpecial $value) False (<= (abs-math $value) 0.0)))

;; PeTTa throws arithmetic errors where Classic carries IEEE infinity or NaN.
;; Preserve that value's category in Error so greater_than_zero can recover it.
(= (numericResult $result $overflow)
   (case $result
     (((Error $type $_)
        ;; catch carries an opaque runtime term, not a MeTTa expression list.
        (case (repr $type)
          (("(evaluation_error float_underflow)" 0.0)
           ("(evaluation_error float_overflow)" (Error $overflow "Numeric overflow"))
           ("(evaluation_error zero_divisor)" (Error $overflow "Numeric overflow"))
           ($other $result))))
      ($value $value))))

(= (numericProductSign $left $right)
   (if (== (numericSign $left) (numericSign $right))
       PositiveInfinity
       NegativeInfinity))

(= (numericSign $value)
   (case $value
     ((PositiveInfinity PositiveInfinity)
      (NegativeInfinity NegativeInfinity)
      ($number
        (if (or (< $number 0.0) (== (repr $number) "-0.0"))
            NegativeInfinity
            PositiveInfinity)))))
