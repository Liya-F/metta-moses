!(import! &self ../../../metta-moses/utilities/general-helpers)
!(import! &self ../../../metta-moses/utilities/list-methods)
!(import! &self ../../../metta-moses/utilities/map)
!(import! &self ../../../metta-moses/utilities/ordered-multimap)
!(import! &self ../../../metta-moses/feature-selection/feature-selection-helpers)
!(import! &self ../../../metta-moses/scoring/precision-bscore)
!(import! &self ../../utilities/enum)

;; Enum strings and typed rows follow Classic's map ordering.
!(assertEqual (enum< (mkEnum "blue") (mkEnum "red")) True)
!(assertEqual (enum< (mkEnum "red") (mkEnum "red")) False)
!(assertEqual (enum< (mkEnum "a") (mkEnum "aa")) True)
!(assertEqual (enum< (mkEnum "red") (mkEnum "blue")) False)
!(assertEqual (row< () ()) False)
!(assertEqual (row< (True) (False)) True)
!(assertEqual (row< (4.9 3.5) (5.1 3.0)) True)
!(assertEqual (row< (5.1 3.0) (5.1 3.5)) True)
!(assertEqual (row< (5.1 3.5) (5.1 3.0)) False)

(= (enumRows)
   ((5.1 3.5 (mkEnum "red"))
    (4.9 3.0 (mkEnum "blue"))
    (5.1 3.5 (mkEnum "blue"))
    (5.1 3.5 (mkEnum "red"))))

!(assertEqual (cTable (enumRows) (A B target) row< tableValue<)
  (((4.9 3.0) (((mkEnum "blue") 1)))
   ((5.1 3.5) (((mkEnum "blue") 1) ((mkEnum "red") 2)))))
!(assertEqual (cTable () (A target) row< tableValue<) ())
!(assertEqual (cTable ((True True) (False False) (True False)) (A target) row< tableValue<)
  (((True) ((True 1) (False 1))) ((False) ((False 1)))))
!(assertEqual (size-atom (collapse (cTable (enumRows) (A B target) row< tableValue<))) 1)

(= (andTable) 
   (mkITable
     (cons (cons True (cons True (cons False (cons False ()))))      
     (cons (cons True (cons False (cons True (cons False ()))))    
     (cons (cons True (cons False (cons False (cons False ())))) ())))
     (cons A (cons B (cons Output ())))))

;; Test data: Precision Table
; this is directy taken from the moses c++ test file
;; reference: https://github.com/opencog/moses/blob/master/tests/moses/precision.csv

(= (precisionTable)
   (mkITable 
     (cons (cons False (cons True (cons False (cons True (cons True (cons False (cons False (cons False (cons False (cons False ())))))))))) 
     (cons (cons False (cons False (cons False (cons False (cons False (cons False (cons False (cons True (cons True (cons True ()))))))))))
     (cons (cons False (cons False (cons False (cons False (cons False (cons True (cons True (cons True (cons True (cons True ())))))))))) ())))
     (cons v1 (cons v2 (cons target ())))))

; Test of count Table
; !(assertEqual (countTable (True True True) 2 ()) (cons ((True True) (1 0)) ()))
; !(assertEqual (countTable (True False False) 2 ()) (cons ((True False) (0 1)) ()))
; !(assertEqual (countTable (True True False) 2 ()) (cons ((True True) (0 1)) ()))
; !(assertEqual (countTable () 0 ()) ())


;; Test of cTable
!(assertEqual (cTable ((True True True) (True False False) (False True False) (False False False)) (A B Output)) 
            (((True True) ((True 1))) ((True False) ((False 1)))
             ((False True) ((False 1))) ((False False) ((False 1))))
  )

!(assertEqual (cTable ((False False False) (True False False) (False False False) (True False False) (True False False) (False False True) (False False True) (False True True) (False True True) (False True True)) (v1 v2 target))
            (((False False) ((False 2) (True 2)))
             ((True False) ((False 3))) ((False True) ((True 3))))
  )


!(assertEqual (makePrecisionRow ((True True) ((True 1))) ()) (cons (0.5 (0.5 1)) ()))
!(assertEqual (makePrecisionRow ((False True) ((False 2))) ()) (cons (-0.5 (-1.0 2)) ()))
!(assertEqual (makePrecisionRow () ()) ())


!(assertEqual (createPrecisionRows (((True True) ((True 1)))
                                  ((True False) ((False 1)))
                                  ((False True) ((False 1)))))
                ;;result 
                ((0.5 (0.5 1)) (-0.5 (-0.5 1)) (-0.5 (-0.5 1)))             
  )

; Test of getActivationPenalty
!(assertEqual (getActivationPenalty 0.5 0.5 1.0 1.0) 0.0)     ;; At minimum boundary -> no penalty
!(assertEqual (getActivationPenalty 0.75 0.5 1.0 0.0) 0.0)    ;; No pressure -> no penalty
!(assertEqual (getActivationPenalty 1.0 0.5 1.0 1.0) 0.0)     ;; At maximum boundary -> no penalty


!(assertEqual (let $penaltyBelow (getActivationPenalty 0.3 0.5 1.0 1.0) (< $penaltyBelow 0)) True)  ;; Should be negative (penalty)

!(assertEqual (let* (
                        ($penalty1 (getActivationPenalty 0.3 0.5 1.0 1.0))
                        ($penalty2 (getActivationPenalty 0.3 0.5 1.0 2.0))
                    )
                    (< $penalty2 $penalty1)) True)  ;; Higher pressure -> more negative penalty

;; Test ExtractTable

(= (testRows) 
            (cons (cons True (cons True (cons False (cons False ()))))
            (cons (cons True (cons False (cons True (cons False ()))))
            (cons (cons False (cons False (cons False (cons False ()))))
            (cons (cons True (cons True (cons True (cons True ())))) 
            (cons (cons True (cons True (cons False (cons False ())))) ()))))))
            
(= (testLabels) (cons A (cons B (cons C (cons D (cons Output ()))))))

!(assertEqual (extractTable (0) (testRows) (testLabels))
                 (((True True) (True True) (False False) (False False)) (A Output))) ;; single feature extraction
!(assertEqual (extractTable (0 1) (testRows) (testLabels)) 
                (((True True True) (True False True) (False True False) (False False False)) (A B Output))) ;; two feature extraction

!(assertEqual (extractTable () (testRows) (testLabels))
            (((True) (True) (False) (False)) (Output))  ;; only extracts the labels
)


; Test of bestPossibleScore
!(assertEqual (let $bestScore (bestPossibleBScore ((0.5 (0.5 1)) (-0.5 (-0.5 1)) (-0.5 (-0.5 1))) 0.0 0.0 4 0.5 1.0 1.0 -1000.0)
            (< $bestScore 1.0)
    ) True
)

!(assertEqual (bestPossibleBScore () 0.0 0.0 4 0.5 1.0 1.0 -1000.0) -1000.0) ;; should return intial score
!(assertEqual (bestPossibleBScore ((1.0 (1.0 2)) (0.5 (0.5 2))) 0.0 0.0 4 0.5 1.0 1.0 0.0) 1.0)

; Test of PrecisionBScore
!(assertEqual (precisionBScore ((True True True) (False False False)) (A B Output) 1.0 0.5 1.0 2) 1.0)

                                                                                                                                                                                                                                                    ;; this is the actual result in the moses test file too for precisionTable which is 5/7 = 0.7142857142857143
                                                                                                                                                                                                                                                    ;; reference: https://github.com/opencog/moses/blob/master/tests/moses/scoringUTest.cxxtest#L55
!(assertEqual (precisionBScore ((False False False) (True False False) (False False False) (True False False) (True False False) (False False True) (False False True) (False True True) (False True True) (False True True)) (v1 v2 target) 1.0 0.5 1.0 10) 0.7142857142857143)

;; Test of prescorer
!(assertEqual (preScorer (1) (andTable) 1.0 0.5 1.0 True 0.001) 0.4000799677107699)
!(assertEqual (preScorer (0 1) (andTable) 1.0 0.5 1.0 True 50.0) 0.5)
!(assertEqual (preScorer (1) (precisionTable) 1.0 0.5 1.0 True 100.0) 0.5)
!(assertEqual (preScorer () (andTable) 1.0 0.5 1.0 True 100.0) 0.0)
;                                                                         ;; this is the actual result in the moses test file too for precisionTable which is 5/7 = 0.7142857142857143
;                                                                         ;; reference: https://github.com/opencog/moses/blob/master/tests/moses/scoringUTest.cxxtest#L55
!(assertEqual (preScorer (0 1) (precisionTable) 1.0 0.5 1.0 True 100.0) 0.7142857142857143)
