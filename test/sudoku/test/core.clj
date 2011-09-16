(ns sudoku.test.core
  (:use [sudoku.core])
  (:use [clojure.test]))

(deftest rows
  (is (= (get-row easy-data 1) [0 0 0  0 0 0  0 0 7]))
  (is (= (get-row easy-data 4) [0 0 7  5 2 8  6 0 0])))

(deftest columns
  (is (= (get-col easy-data 1) [0 7 0  0 0 9  0 6 4]))
  (is (= (get-col easy-data 4) [0 0 8  5 0 4  7 0 0])))

(deftest cells
  (is (= (get-cell easy-data 1 1) 0))
  (is (= (get-cell easy-data 9 9) 8))
  (is (= (get-cell easy-data 1 9) 7))
  (is (= (get-cell easy-data 9 1) 4))
  (is (= (get-cell easy-data 5 5) 0)))

(deftest boxes
  (is (= (get-box easy-data 1 1) [0 0 0  7 0 4  0 0 6]))
  (is (= (get-box easy-data 6 1) [0 0 7  0 8 0  9 0 3]))
  (is (= (get-box easy-data 7 7) [9 0 0  0 0 0  1 0 8]))
  (is (= (get-box easy-data 4 8) [6 0 0  7 0 1  0 8 0])))

(deftest zeros
  (is (= (apply get-cell easy-data (take 2(first-zero easy-data))) 0)))

(deftest solver
  (is (= (solve easy-data)
          [8 1 5  3 4 9  2 6 7
           7 2 4  6 5 1  8 9 3
           3 9 6  8 7 2  4 1 5

           1 4 7  5 2 8  6 3 9
           5 8 2  9 3 6  7 4 1
           9 6 3  4 1 7  5 8 2

           2 3 1  7 8 4  9 5 6
           6 7 8  1 9 5  3 2 4
           4 5 9  2 6 3  1 7 8])))
