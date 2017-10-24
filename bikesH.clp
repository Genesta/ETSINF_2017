(defglobal ?*nod-gen* = 0)
(defglobal ?*f* = 0)

(deffacts min_paths
(min_path A 8)
(min_path B 5)
(min_path C 5)
(min_path D 6)
(min_path E 9)
(min_path F 6)
(min_path G 6)
(min_path H 6)
(min_path I 2)
(min_path J 7)
(min_path K 2)
(min_path L 2)
(min_path M 2)
(min_path N 6)
(min_path O 2)
(min_path P 2)
(min_path R 3)
)

(deffacts neighbourhoods
(neighbourhood A 1)
(neighbourhood B 2)
(neighbourhood C 2)
(neighbourhood D 2)
(neighbourhood E 2) 
(neighbourhood F 3)
(neighbourhood G 3)
(neighbourhood H 3)
(neighbourhood I 3)
(neighbourhood J 2)
(neighbourhood K 4) 
(neighbourhood L 4)
(neighbourhood M 4)
(neighbourhood N 4)
(neighbourhood O 3)
(neighbourhood P 5)
(neighbourhood Q 5)
(neighbourhood R 6)
)


(deffunction h1 (?b1 ?b2 ?min ?have_bike ?is_station)
        (bind ?h 0)
        (if (eq ?b1 ?b2)
	  then    (bind ?h 1)
	  else   (bind ?h (abs (- ?b1 ?b2)))
       )
       (bind ?h (* ?h ?min))
       (if (or(eq ?have_bike yes)(eq ?is_station yes))
       	then (bind ?h (* ?h 0.5))
       	else (bind ?h (* ?h 1))
       )
       (integer ?h) ;return ?h
)

(deffunction control (?g ?b1 ?b2 ?min ?have_bike ?is_station)
    (bind ?*f* (h1 ?b1 ?b2 ?min ?have_bike ?is_station))
    (bind ?*f* (+ ?*f* ?g))
)

(deffacts map
  (path A B 10 bike)
  (path A C 8 foot)
  (path A E 10 bike)
  (path B C 5 foot)
  (path B F 6 foot)
  (path C D 6 foot)
  (path C G 6 foot)
  (path C H 6 foot)
  (path D H 14 bike)
  (path E I 20 foot)
  (path E J 9 bike)
  (path F K 10 foot)
  (path F L 6 foot)
  (path G H 8 foot)
  (path G L 9 foot)
  (path G M 12 foot)
  (path H I 12 bike)
  (path I O 2 foot)
  (path J O 7 bike)
  (path K L 2 bike)
  (path L M 7 bike)
  (path L P 6 bike)
  (path M Q 2 foot)
  (path N Q 6 foot)
  (path N O 8 bike)
  (path O I 2 foot)
  (path P Q 2 foot)
  (path P R 4 bike)
  (path B A 10 bike)
  (path C A 8 foot)
  (path E A 10 bike)
  (path C B 5 foot)
  (path F B 6 foot)
  (path D C 6 foot)
  (path G C 6 foot)
  (path H C 6 foot)
  (path H D 14 bike)
  (path I E 20 foot)
  (path J E 9 bike)
  (path K F 10 foot)
  (path L F 6 foot)
  (path H G 8 foot)
  (path L G 9 foot)
  (path M G 12 foot)
  (path I H 12 bike)
  (path O I 2 foot)
  (path O J 7 bike)
  (path L K 2 bike)
  (path M L 7 bike)
  (path P L 6 bike)
  (path Q M 2 foot)
  (path Q N 6 foot)
  (path O N 8 bike)
  (path I O 2 foot)
  (path Q P 2 foot)
  (path R P 4 bike)
)


(deffacts stations
  (station A yes)
  (station B yes)
  (station C no)
  (station D no)
  (station E no)
  (station F no)
  (station G no)
  (station H yes)
  (station I no)
  (station J yes)
  (station K yes)
  (station L no)
  (station M yes)
  (station N yes)
  (station O no)
  (station P no)
  (station Q no)
  (station R yes)
)




(defrule walking
  (declare (salience (- 0 ?*f*)))
  (state current ?x dest ?d bike ?have_bike cost ?c level ?n)
  (path ?x ?y ?cc ?)
  (max-depth ?deep)
  (test (< ?n ?deep))
  (neighbourhood ?y ?b1)
  (neighbourhood ?d ?b2)
  (min_path ?y ?min)
  (station ?y ?is_station)
  (test (control (+ ?cc ?c) ?b1 ?b2 ?min  ?have_bike ?is_station))
    =>
  (assert (state current ?y dest ?d bike ?have_bike cost (+ ?c ?cc) level (+ ?n 1)))
  (bind ?*nod-gen* (+ ?*nod-gen* 1))
  (printout t "Walking. Last state: " ?x " Cost: " ?c " Level:" ?n crlf)
)


(defrule cyclig
  (declare (salience (- 0 ?*f*)))
  (state current ?x dest ?d bike yes cost ?c level ?n)
  (path ?x ?y ?cc bike)
  (max-depth ?deep)
  (test (< ?n ?deep))
  (neighbourhood ?y ?b1)
  (neighbourhood ?d ?b2)
  (min_path ?y ?min)
  (station ?y ?is_station)
  (test (control (+ ?c (div ?cc 2)) ?b1 ?b2 ?min yes ?is_station))
    =>
  (assert (state current ?y dest ?d bike yes cost (+ ?c (div ?cc 2) ) level (+ ?n 1)))
  (bind ?*nod-gen* (+ ?*nod-gen* 1))
  (printout t "Cycling. Last state: " ?x " Cost: " ?c " Level:" ?n crlf)
)


(defrule take_bike
  (declare (salience (- 0 ?*f*)))
  (state current ?x dest ?d bike no cost ?c level ?n)
  (station ?x yes)
  (neighbourhood ?x ?b1)
  (neighbourhood ?d ?b2)
  (min_path ?x ?min)
  (test (control (+ 1 ?c) ?b1 ?b2 ?min yes yes))
  =>
  (assert (state current ?x dest ?d bike yes cost (+ ?c 1) level (+ ?n 1)))
  (printout t "Bike taken at: " ?x " Cost: " ?c crlf)
)


(defrule drop_bike
  (declare (salience (- 0 ?*f*)))
  (state current ?x dest ?d bike yes cost ?c level ?n)
  (station ?x yes)
  (neighbourhood ?x ?b1)
  (neighbourhood ?d ?b2)
  (min_path ?x ?min)
  (test (control (+ 1 ?c) ?b1 ?b2 ?min no yes))
  =>
  (assert (state current ?x dest ?d bike no cost (+ ?c 1) level(+ ?n 1)))
  (printout t "Bike dropped at: " ?x " Cost: " ?c crlf)
)


(defrule stop
  (declare (salience 10))
  (state current ?x dest ?x bike no cost ?c level ?n)
  =>
  (halt)
  (printout t "Sol. found at level: " ?n " Nodes: " ?*nod-gen* " Cost: " ?c crlf)
)
	

(deffunction start()
	(set-salience-evaluation when-activated)
	(reset)
	(printout t "Maximum depth:= ")
	(bind ?deep (read))
	(printout t "Search type " crlf "    1.- Breadth" crlf "    2.- Depth" crlf )
	(bind ?a (read))
	(if (= ?a 1)
	  then    (set-strategy breadth)
	  else   (set-strategy depth))
	(assert (max-depth ?deep))
	(assert (state current A dest R bike no cost 0 level 0))
)
;;(deffacts initial (state current B dest M bike no cost 0 level 1))