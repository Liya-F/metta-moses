(= (member-node $node $list)
    (case $list
        (
            ( (Cons $h $t)
                (if (== $node $h) True
                    (member-node $node $h)))
            ( (TreeNode $nodeValue $leftChild $rightChild $guardSet $listOfChildren)
                (if (== $node $leftChild)
                    True
                    (if (== $node $rightChild)
                        True
                        (if (member-node $node $leftChild)
                            True
                            (member-node $node $rightChild))))
            )
        ($else False)

    )
)
)
 ;testcase
! (member-node (TreeNode (Value b False NOT) Nil
        Node NilNode NilList NilList) (Cons (TreeNode (Value Nil False AND) (TreeNode (Value a False NOT) NilNode NilNode NilList NilList) (TreeNode (Value b False NOT) Nil
                Node NilNode NilList NilList) NilList NilList) ()))