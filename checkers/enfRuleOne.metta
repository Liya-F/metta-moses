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

! (check-negation (and $a $b))
! (check-negation (and (or $a $b) (or $a $b)))
! (check-negation (and (not a) (not b)))

! (check-negation (not (and a b)))
! (check-negation (not (and (not a) (not (or b c)))))
! (check-negation (not (and (not a) (not (or b c)))))