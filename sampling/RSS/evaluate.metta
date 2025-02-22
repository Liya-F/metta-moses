;; generate a fitness score based on the closeness to the target program (program 2)
(=(fitness ($program $index) $targetIndex)
   (let* (
      ;; calculate the absolute difference between the program index and the target index
      ($distance (abs (- $index $targetIndex)))
      ;; calculate the fitness score based on the distance
      ($fitnessScore (/ 1 (+ 1 $distance)))
   )
   ;; return the program with its calculated fitness score
   (program $index $fitnessScore)
))

;; evaluates programs based on their closeness to the target program (program 2)
(=(evaluate $population $dataset)
   (case $population
      ;; For each program in the population, calculate its fitness based on closeness to program 2
      (((program $index) (fitness $index 2))
      ;; Otherwise, process the whole population
      ($population (collapse (fitness (superpose $population) 2)))
   )
)

;; test cases
;; generate fitness for individual programs
!(fitness (program 11 0) 2)   ;; this will calculate the fitness of program 11 based on its closeness to program 2

;; evaluate a population of programs based on their closeness to program 2
!(evaluate 
   ((program 0) (program 1) (program 2) (program 3) (program 4) 
    (program 5) (program 6) (program 7) (program 8) (program 9) (program 10))
   ((data_point 8) (data_point 13) (data_point 21) (data_point 11))) 
