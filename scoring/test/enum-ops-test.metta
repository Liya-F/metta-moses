!(import! &self ../../moses-imports)

;; A and B are existing Boolean predicates. X and Y are enum input columns.
(= (enumEvalTable)
   (mkITable
     ((True False False True)
      (True True False False)
      ((mkEnum "red") (mkEnum "blue") (mkEnum "red") (mkEnum "blue"))
      ((mkEnum "blue") (mkEnum "red") (mkEnum "blue") (mkEnum "red")))
     (A B X Y)))

;; Quote wrapped operator expressions so their heads do not execute as data is built.
(= (runCond $exp)
   (evalSubtree $exp (enumEvalTable) 4))

!(assertEqual (runCond (mkEnum "red"))
  ((mkEnum "red") (mkEnum "red") (mkEnum "red") (mkEnum "red")))
!(assertEqual (runCond (quote (cond (A (mkEnum "red") (mkEnum "blue")))))
  ((mkEnum "red") (mkEnum "blue") (mkEnum "blue") (mkEnum "red")))
!(assertEqual (runCond (quote (cond (A (mkEnum "red") B (mkEnum "blue") (mkEnum "green")))))
  ((mkEnum "red") (mkEnum "blue") (mkEnum "green") (mkEnum "red")))
!(assertEqual (runCond (quote (cond ((AND (A B)) (mkEnum "red") (mkEnum "blue")))))
  ((mkEnum "red") (mkEnum "blue") (mkEnum "blue") (mkEnum "blue")))
!(assertEqual (runCond (quote (cond ((NOT (A)) (mkEnum "red") (mkEnum "blue")))))
  ((mkEnum "blue") (mkEnum "red") (mkEnum "red") (mkEnum "blue")))
!(assertEqual (runCond (quote (cond (A X Y))))
  ((mkEnum "red") (mkEnum "red") (mkEnum "blue") (mkEnum "blue")))
!(assertEqual (runCond (quote (cond (A (cond (B X Y)) (mkEnum "green")))))
  ((mkEnum "red") (mkEnum "green") (mkEnum "green") (mkEnum "red")))
!(assertEqual (runCond (quote (cond ((mkEnum "green")))))
  ((mkEnum "green") (mkEnum "green") (mkEnum "green") (mkEnum "green")))

;; Missing labels would fail if an unselected answer or later condition ran.
!(assertEqual (runCond (quote (cond (True (mkEnum "red") Missing (mkEnum "green") Missing))))
  ((mkEnum "red") (mkEnum "red") (mkEnum "red") (mkEnum "red")))
!(assertEqual (runCond (quote (cond (False Missing (mkEnum "blue")))))
  ((mkEnum "blue") (mkEnum "blue") (mkEnum "blue") (mkEnum "blue")))
!(assertEqual
  (evalTableRow (quote (cond ())) (enumEvalTable) 0)
  (Error cond "Expected condition-answer pairs and a fallback"))
!(assertEqual
  (evalTableRow (quote (cond (False (mkEnum "red")))) (enumEvalTable) 0)
  (Error cond "Expected condition-answer pairs and a fallback"))
;; Classic returns a matching answer immediately, without inspecting the remaining tail.
!(assertEqual
  (evalTableRow (quote (cond (True (mkEnum "red")))) (enumEvalTable) 0)
  (mkEnum "red"))
!(assertEqual
  (size-atom (collapse (runCond (quote (cond (A X Y))))))
  1)

;; A production candidate still uses the existing mkTree and preOrderExp.
!(assertEqual
  (runCond
    (preOrderExp
      (mkTree (mkNode cond)
        ((mkTree (mkNode A) ())
         (mkTree (mkNode (mkEnum "red")) ())
         (mkTree (mkNode (mkEnum "blue")) ())))))
  ((mkEnum "red") (mkEnum "blue") (mkEnum "blue") (mkEnum "red")))
!(assertEqual
  (runCond (quote (cond (A (cond (B True False)) False))))
  (True False False False))
!(assertEqual
  (runCond (preOrderExp (mkTree (mkNode cond) ())))
  ((Error cond "Expected condition-answer pairs and a fallback")
   (Error cond "Expected condition-answer pairs and a fallback")
   (Error cond "Expected condition-answer pairs and a fallback")
   (Error cond "Expected condition-answer pairs and a fallback")))
