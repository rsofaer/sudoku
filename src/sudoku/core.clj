(ns sudoku.core
  (:require [org.danlarkin.json :as json])
  (:use clojure.set
        clojure.contrib.combinatorics)
  (:gen-class))

(def input-data
  ((json/decode (slurp "in.json")) :rows))
(def nums #{1 2 3 4 5 6 7 8 9})
(def pairs (cartesian-product (range 1 10) (range 1 10)))

(defn get-row [mat i] (nth mat (- i 1)))
(defn get-col [mat j] (map #(nth % (- j 1)) mat))
(defn get-cell [mat i j] (nth (get-row mat i) (- j 1)))
(defn get-zeros [mat] (map (filter #(= (first %) 0) (map (fn [[i j]] [(get-cell mat i j) [i j]]) pairs)))


(defn block-n [i-or-j] (nth [1,1,1,2,2,2,3,3,3] (- i-or-j 1)))
(defn get-box [mat i j]
  (let [i-block (block-n i)
        j-block (block-n j)
        rows (subvec mat (- (* i-block 3) 3) (* i-block 3))]
    (flatten 
      (map (fn [row] (subvec row (- (* j-block 3) 3) (* j-block 3)) ) rows))))
(defn nums-remaining [mat i j] 
  (if (= (get-cell mat i j) 0)
      (difference nums (union (set (get-row mat i)) (set (get-col mat j)) (set (get-box mat i j))))
      #{}))

(defn -main []
  (println (input-data)))
