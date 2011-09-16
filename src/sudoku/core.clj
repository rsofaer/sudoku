(ns sudoku.core
  (:require [org.danlarkin.json :as json])
  (:use clojure.set
        clojure.contrib.combinatorics)
  (:gen-class))

(def nums #{1 2 3 4 5 6 7 8 9})
(def pairs (cartesian-product (range 1 10) (range 1 10)))
(defn print-return [a] (println a) a)

(defn get-row [mat i] (let [idx (* 9 (dec i))]
  (take 9 (drop idx mat))))
(defn get-col [mat j] (take-nth 9 (drop (dec j) mat)))
(defn get-cell [mat i j] 
  (nth (get-row mat i) (dec j)))
(defn get-zeros [mat] (map (filter #(= (first %) 0) (map (fn [[i j]] [(get-cell mat i j) [i j]]) pairs))))


(defn block-n[i-or-j] 
  (quot (- i-or-j 1) 3))

(defn get-box [mat i j]
  (let [i-block (block-n i)
        j-block (block-n j)]
    (vec (flatten (nth (partition 3 (take-nth 3 (nthnext (partition 3 mat) j-block))) i-block )))))

(defn nums-remaining [mat idx] 
  (let [i (inc (quot idx 9))
        j (inc (rem idx 9))]
    (if (= (get-cell mat i j) 0)
        (difference nums (union (set (get-row mat i)) (set (get-col mat j)) (set (get-box mat i j))))
        nil)
    ))


(defn consistent? [mat] 
  (let [possibilities (map #(apply nums-remaining mat %) pairs)]
    (every? (fn [set] (or (nil? set) (> (count set) 0))) possibilities)))

(defn solved? [mat] (and (not (nil? mat)) (consistent? mat) (not-any? #(= % 0) mat)))

(defn set-at-index [v e idx] 
  (concat (take idx v) [e] (drop (+ idx 1) v)))
(defn first-zero [mat]
  (let [idx (.indexOf mat 0)]
    [(inc (quot idx 9)) (inc (rem idx 9)) idx]))

(defn solve [mat]
  (println mat)
  (let [idx (.indexOf mat 0)]
    (if (= -1 idx)
      mat
      (let [nums (nums-remaining mat idx)]
      (if (= 0 (count nums))
        nil
        (let [paths (filter #(not (nil? %)) 
                      (map (fn [n] (solve (set-at-index mat n idx))) nums ))]
          (if (empty? paths)
            nil
            (first paths))))))))

(def easy-data
   [0 0 0  0 0 0  0 0 7
    7 0 4  0 0 0  8 9 3
    0 0 6  8 0 2  0 0 0

    0 0 7  5 2 8  6 0 0
    0 8 0  0 0 6  7 0 1
    9 0 3  4 0 0  0 8 0

    0 0 0  7 0 4  9 0 0
    6 0 0  0 9 0  0 0 0
    4 5 9  0 0 0  1 0 8])

(def hard-data
  [0 3 0  0 0 0  0 4 0
   0 1 0  0 9 7  0 5 0
   0 0 2  5 0 8  6 0 0
  
   0 0 3  0 0 0  8 0 0
   9 0 0  0 0 4  3 0 0
   0 0 7  6 0 0  0 0 4
  
   0 0 9  8 0 5  4 0 0
   0 7 0  0 0 0  0 2 0
   0 5 0  0 7 1  0 8 0])

(def ecco-data
  [7 0 0  0 0 0  0 6 4
   0 0 6  0 0 0  0 0 0
   0 0 0  0 0 8  0 2 0
  
   5 6 3  0 0 0  0 0 0
   0 0 0  0 7 0  2 0 9
   0 0 0  0 0 0  0 0 0
  
   0 5 0  0 0 0  3 0 0
   0 0 0  4 0 0  0 9 0
   1 7 0  9 0 0  0 0 8])
(defn -main []
  (println (partition 3 (solve hard-data))))
