(: check-negation (-> Expression Bool))
(= (check-negation $exp)
    (case $exp
        (
            ( ($OP $a $b) (and
                    (if (== (get-metatype $a) Expression)
                        (check-negation $a)
                        True ; True if it's not an expression
                    )

                (if (== (get-metatype $b) Expression)
                    (check-negation $b)
                    True ; True if it's not an expression
                )
        ))

( (not $a)
    (if (== (get-metatype $a) Expression) False True) )

( $else True)
)
)
)
