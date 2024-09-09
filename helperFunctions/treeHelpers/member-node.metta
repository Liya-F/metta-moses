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
