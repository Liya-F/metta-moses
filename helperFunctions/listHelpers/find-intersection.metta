 ; Function to check if an element is in a list
(= (member $x $y)
    (case $y
        (
            ( (:: $h $t) (if (== $x $h) True (member $x $t)))
            ( () False)
        )
)
)
! (member 2 (:: 2 (:: 7 (:: 3 ())))) ;True
! (member 4 (:: 2 (:: 7 (:: 3 ())))) ;False