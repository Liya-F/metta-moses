(= (applyOrCut $child $current)
    (case ($child $current)
        (
            ( ( (TreeNode $nodeValueCh $guardSetCh $listOfChildrenCh) (TreeNode $nodeValueCr $guardSetCr $listOfChildrenCr))
                (if (== (length $listOfChildrenCh) 1)
                    (case $listOfChildrenCh
                        (
                            ( (Cons (TreeNode $nodeValueGr $guardSetGr $listOfChildrenGr) Nil)
                                (TreeNode $nodeValueCr (setUnion $guardSetCr $guardSetGr) (findAndRemoveTree (TreeNode $nodeValueGr $guardSetGr $listOfChildrenGr) (extend $listOfChildrenGr $listOfChildrenCr)))
                            )
                        ($else ())
                    )
            )
        (TreeNode $nodeValueCr $guardSetCr $listOfChildrenCr)
    )
)
($else ())
)
)
)

 ;testcase
! (applyOrCut (TreeNode (valueCh) (guardsetCh) (Cons (TreeNode (Value a False LITERAL) (Cons 1 (Cons 2 (Cons 1 Nil))) (Cons (TreeNode (Value b False LITERAL) Nil Nil) (Cons (TreeNode (Value c False LITERAL) Nil Nil) Nil))) Nil))
    (TreeNode (valueCr) (Cons 4 (Cons 5 (Cons 1 Nil))) (Cons (TreeNode (Value a False LITERAL) (Cons 1 (Cons 2 (Cons 1 Nil))) (Cons (TreeNode (Value b False LITERAL) Nil Nil) (Cons (TreeNode (Value c False LITERAL) Nil Nil) Nil))) (Cons (TreeNode (Value c False LITERAL) Nil Nil) (Cons (TreeNode (Value d False LITERAL) Nil Nil) Nil)))))
