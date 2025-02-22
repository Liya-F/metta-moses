!(register-module! ../../../metta-moses)
!(import! &self metta-moses:sampling:RSS:dataset:data)
!(import! &self metta-moses:sampling:RSS:dataset:program)
!(import! &self metta-moses:sampling:RSS:RSSHelpers)
!(import! &self metta-moses:sampling:RSS:evaluate)
!(import! &self metta-moses:sampling:RSS:evolve)

!(bind! &data (new-space))
!(bind! &program (new-space))

;; add Data to space
!(manuplateSpace add-atom &data (collapse (match &self (data_point $index) (data_point $index $index))))
!(manuplateSpace add-atom &program (collapse (match &self (program $index) (program $index $index 0))))

;;selects sample dataset of size $subset_size from the $data space
(= (selectSubset $subsetSize $dataSize)(
   collapse (let $randomIndex (random $subsetSize $dataSize ()) 
      (selectSubsetHelper (superpose $randomIndex))
   )
))

;searches data in the space
(= (selectSubsetHelper $randVal)
   (collapse (superpose (match &data ($x $randVal $y) ($x $y))))
)

;;returns the programs inside the &program space
(= (getPrograms $programs)
   (case $programs(
      (() (collapse (match &program ($program $index $index $score) ($program $index $score))))
      ($programs $programs)
   ))
)

;; Fitness based on closeness to program 2
(=(fitness ($program $index) $targetIndex)
   (let* (
      ;; calculate the absolute difference between the program index and the target index (program 2)
      ($distance (abs (- $index $targetIndex)))
      ;; calculate the fitness score based on the distance
      ($fitnessScore (/ 1 (+ 1 $distance)))
   )
   ;; return the program with its calculated fitness score
   (program $index $fitnessScore)
))

;; Evaluates programs based on their closeness to the target program (program 2)
(=(evaluate $population $dataset)
   (case $population
      ;; For each program in the population, calculate its fitness based on closeness to program 2
      (((program $index) (fitness $index 2))
      ;; Otherwise, process the whole population
      ($population (collapse (fitness (superpose $population) 2)))
   )
)

;;params 
;;     n:number of generations
;;     $programs: programs
;;     $dataset: sample dataset
(=(generation $n $programs $dataset)
  (let* ( ( ()  (println! (------ $n Generation  ------)))
          ( ()  (println! (Random subset generated : $dataset)))
          ($programs (getPrograms $programs))
          ($evaluated_programs (evaluate $programs $dataset))  ;; This now uses our closeness-based fitness evaluation
          ( ()  (println! (programs evaluated : $evaluated_programs)))
          ($new_generaion (evolve $evaluated_programs))
          ( ()  (println! (programs generated : $new_generaion)))
          ($new_random_subset (selectSubset 4 25))
          ( ()  (println! (New Random subset generated!)))
        )
       (if(== (- $n 1) 0)
          $new_generaion
          (generation (- $n 1) $new_generaion $new_random_subset)
       )
   )
)

;; testcase
!(generation 5 ((program 1 0) (program 2 0)) (selectSubset 4 25))
