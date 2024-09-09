 ; Function to check if an element is in a list
(= (member $x $y)
    (case $y
        (
            ( (:: $h $t) (if (== $x $h) True (member $x $t)))
            ( () False)
        )
)
)
