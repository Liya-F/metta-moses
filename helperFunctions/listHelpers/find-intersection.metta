 ; Function to check if an element is in a list
(= (member $x $y)
    (case $y
        (
            ( (Cons $h $t) (if (== $x $h) True (member $x $t)))
            ( () False)
        )
)
)
! (member 2 (Cons 2 (Cons 7 (Cons 3 ())))) ;True
! (member 4 (Cons 2 (Cons 7 (Cons 3 ())))) ;False

 ;function to return the intersection of two lists
(= (find-intersection $lst1 $lst2)
    (case $lst1
        (
            ( (Cons $h $t)
                (if (member $h $lst2)
                    (Cons $h (find-intersection $t $lst2))
                    (find-intersection $t $lst2)) )
            ( () () )
        )
)
)

! (find-intersection (Cons 1 (Cons 4 (Cons Hello (Cons 2 (Cons 9 ()))))) (Cons 1 (Cons 4 (Cons Hi (Cons hello (Cons 7 ()))))))
