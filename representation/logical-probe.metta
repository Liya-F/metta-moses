;;;;;;;;;; Logical Probe ;;;;;;;;;;;
;; logicalProbe builds LSKs by processing the sampleLogicalPerms 
;; Params:
;;      $exemplar: Reference tree containing the target node.
;;      (mkNodeId $targetId): ID of the target node in the exemplar.
;;      $perms: Tuple of trees
;;      $addIfInExemplar: If true, include knobs even if in exemplar.
;;      $knobs: the list of knobs at each iteration, () at the start
;; Return: a tuple containing a tuple of LSKs and the final updated tree

;; logicalProbe
;; (: logicalProbe (-> (Tree $a) NodeId Expression Bool Expression Expression))
(= (logicalProbe $exemplar (mkNodeId $targetId) () $addIfInExemplar $knobs) ($knobs $exemplar))
(= (logicalProbe $exemplar (mkNodeId $targetId) $perms $addIfInExemplar $knobs)
(let*
(
    (($headPerms $tailPerms) (decons-atom $perms))
    (($updatedTree $lsk) (eval (logicalSubtreeKnob $exemplar (mkNodeId $targetId) $headPerms)))
    ($discKnob (getDiscKnob $lsk))
)
(if (== $addIfInExemplar True ) ;; (not (eval (inExemplar $discKnob)) )) Fix unComment if addIfInExemplar can be False  
    (let* 
    (
        ($updatedKnobs (concatT $knobs ($lsk)))
    )
    (logicalProbe $updatedTree (mkNodeId $targetId) $tailPerms $addIfInExemplar $updatedKnobs)
    )
    (logicalProbe $exemplar (mkNodeId $targetId) $tailPerms $addIfInExemplar $knobs))))
(= (tr $expr) (a (inExemplar (mkDiscKnob $knob $multiplicity (mkDiscSpec 0) (mkDiscSpec 1) Nil))))
