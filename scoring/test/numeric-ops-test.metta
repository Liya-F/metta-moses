!(import! &self ../../moses-imports)

;; Evaluation tests use the production operator imports and existing tree shape.
(= (numericTable)
   (mkITable ((1.4 1.4 1.3 1.5 1.4) (True False True False True))
             (petal_length A)))
(= (numericRow $exp)
   (evalTableRow $exp (numericTable) 0))

!(assertEqual (numericRow (quote (plus (1 2 3)))) 6.0)
!(assertEqual (numericRow (quote (times (2 3 4)))) 24.0)
!(assertEqual (numericRow (quote (div (6 2)))) 3.0)
!(assertEqual (numericRow (quote (sin (0)))) 0.0)
!(assertEqual (numericRow (quote (exp (0)))) 1.0)
!(assertEqual (numericRow (quote (log (1)))) 0.0)
!(assertEqual
  (< (abs-math (- (numericRow (quote (log ((exp (1)))))) 1.0)) 1.0e-12)
  True)
!(assertEqual (numericRow (quote (impulse (True)))) 1.0)
!(assertEqual (numericRow (quote (impulse (False)))) 0.0)
!(assertEqual (numericRow (quote (greater_than_zero (0)))) False)
!(assertEqual (numericRow (quote (greater_than_zero (-2)))) False)
!(assertEqual (numericRow (quote (greater_than_zero (2)))) True)

;; Classic skips later factors after a zero product, and a zero numerator skips the divisor.
!(assertEqual (numericRow (quote (times (0.0 Missing)))) 0.0)
!(assertEqual (numericRow (quote (div (0.0 Missing)))) 0.0)
!(assertEqual (numericRow (quote (div (0 Missing)))) 0.0)
!(assertEqual (numericRow (quote (log (0)))) (Error NegativeInfinity "Numeric overflow"))
!(assertEqual (numericRow (quote (greater_than_zero ((div (1.0 0.0)))))) True)
!(assertEqual (numericRow (quote (greater_than_zero ((div (-1.0 0.0)))))) False)
!(assertEqual (numericRow (quote (greater_than_zero ((div (1.0 -0.0)))))) False)
!(assertEqual (numericRow (quote (greater_than_zero ((log (0.0)))))) False)
!(assertEqual (numericRow (quote (greater_than_zero ((log (-1.0)))))) False)
!(assertEqual (numericRow (quote (greater_than_zero ((exp (1000.0)))))) True)
;; Overflow stops expression evaluation before later children run.
!(assertEqual
  (numericRow (quote (greater_than_zero ((plus ((exp (1000.0)) Missing))))))
  True)

;; Classic + and * do not throw on overflow: subsequent arithmetic still runs.
!(assertEqual
  (numericRow (quote (greater_than_zero ((times (1.0e308 1.0e308 0.0))))))
  False)
!(assertEqual
  (numericRow (quote (greater_than_zero ((plus ((times (1.0e308 1.0e308)) (times (-1.0e308 1.0e308))))))))
  False)

;; First five Iris petal lengths; no expected class is used to choose an answer.
!(assertEqual
  (evalSubtree
    (quote (cond ((greater_than_zero ((plus (2.5 (times (-1 petal_length))))))
                 (mkEnum "Iris-setosa") (mkEnum "Iris-versicolor"))))
    (numericTable) 5)
  ((mkEnum "Iris-setosa") (mkEnum "Iris-setosa") (mkEnum "Iris-setosa")
   (mkEnum "Iris-setosa") (mkEnum "Iris-setosa")))
!(assertEqual
  (evalSubtree (quote (greater_than_zero ((plus (1.4 (times (-1 petal_length)))))))
              (numericTable) 5)
  (False False True False False))
!(assertEqual
  (size-atom (collapse (numericRow (quote (plus (1 2 3))))))
  1)

;; The real Iris CSV has 50 petal lengths below 2.5 and 100 above it.
!(set-param inputFile "examples/iris/iris.csv")
!(set-param targetFeature "class")
!(resetSubtreeCache)
!(assertEqual
  (evalSubtree
    (preOrderExp
      (mkTree (mkNode cond)
        ((mkTree (mkNode greater_than_zero)
           ((mkTree (mkNode plus)
              ((mkTree (mkNode 2.5) ())
               (mkTree (mkNode times)
                 ((mkTree (mkNode -1) ())
                  (mkTree (mkNode petal_length) ())))))))
         (mkTree (mkNode (mkEnum "Iris-setosa")) ())
         (mkTree (mkNode (mkEnum "Iris-versicolor")) ()))))
    (resolve-itable) 150)
  (append (List.repeat 50 (mkEnum "Iris-setosa"))
          (List.repeat 100 (mkEnum "Iris-versicolor"))))
