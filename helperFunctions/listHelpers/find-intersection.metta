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

 ;function to return the intersection of two lists
(= (find-intersection $lst1 $lst2)
    (case $lst1
        (
            ( (:: $h $t) (if (member $h $lst2) (:: $h (find-intersection $t $lst2)) (find-intersection $t $lst2)) )
            ( () () )
        )
)
)