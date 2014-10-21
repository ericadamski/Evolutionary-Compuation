extensions [matrix]

breed [ants ant]
undirected-link-breed [edges edge]
breed [nodes node]

globals [city_coordinates
         best_tour
         best_tour_cost
         nn]

edges-own [city_a
           city_b
           cost
           pheromone]

nodes-own [candidate_list
           candidate_sum]

ants-own [tour
          tour_cost]

patches-own [is_city?]

;;; Observer Functions
to setup
  clear-all
  reset-ticks
  
  set-default-shape nodes "circle"
  
  set show_pheromones? false
  set show_cities? true
  
  set city_coordinates matrix:from-row-list [
    [37 52]
    [49 49]
    [52 64]
    [20 26]
    [40 30]
    [21 47]
    [17 63]
    [31 62]
    [52 33]
    [51 21]
    [42 41]
    [31 32]
    [5 25]
    [12 42]
    [36 16]
    [52 41]
    [27 23]
    [17 33]
    [13 13]
    [57 58]
    [62 42]
    [42 57]
    [16 57]
    [8 52]
    [7 38]
    [27 68]
    [30 48]
    [43 67]
    [58 48]
    [58 27]
    [37 69]
    [38 46]
    [46 10]
    [61 33]
    [62 63]
    [63 69]
    [32 22]
    [45 35]
    [59 15]
    [5 6]
    [10 17]
    [21 10]
    [5 64]
    [30 15]
    [39 10]
    [32 39]
    [25 32]
    [25 55]
    [48 28]
    [56 37]
    [30 40]
  ]

  
  setup_cities
  setup_nnh
  setup_edges
  setup_candidates
  setup_ants 
  
  set best_tour get_random_path
  set best_tour_cost get_tour_length best_tour
  
  update_best_tour
end

to go
  ask ants [
    set tour get_path
    set tour_cost get_tour_length tour
  ]
  find_best_tour
  update_pheromone
  tick
end

;;; Setup Functions
to setup_ants
  create-ants num_ants [
    choose_location
    set tour []
    set tour_cost 0
  ]
  ask ants [set color red]
  ask ants [set size 2
            set shape "default" 
            show-turtle]
end

to setup_candidates
  ask nodes [
    set candidate_list []
    let remaining_cities [self] of nodes
    set remaining_cities sort-by [ calculate_distance self ?1 < calculate_distance self ?2 ] remove self remaining_cities
    set candidate_list sublist remaining_cities 0 cl
    set candidate_sum sum map [ (pheromone_of ?) * (cost_of ?) ^ beta ] map [ edge_with? self ? ] filter [ member? ? candidate_list ] [self] of nodes
  ]
end

to choose_location
  let random_city random first (matrix:dimensions city_coordinates)
  setxy ( matrix:get city_coordinates random_city 0 ) 
        ( matrix:get city_coordinates random_city 1 )
end

to setup_cities
  ask patches [ set is_city? false ]
  
  let i 0
  let s matrix:dimensions city_coordinates
  while [ i < first s ] [
    ask patch ( matrix:get city_coordinates i 0 ) 
              ( matrix:get city_coordinates i 1 ) [ set is_city? true ]
    create-nodes 1 [ 
      setxy ( matrix:get city_coordinates i 0 ) 
            ( matrix:get city_coordinates i 1 ) 
      set color white
      set size 0.9
    ]
    set i i + 1
  ]
end

to setup_nnh
  set nn 0 
  let remaining_cities [self] of nodes
  let current_city first remaining_cities
  let start current_city
  set remaining_cities but-first remaining_cities
  while [ not empty? remaining_cities ] [
    set remaining_cities sort-by [ calculate_distance current_city ?1 < calculate_distance current_city ?2 ] remaining_cities
    let closest_city first remaining_cities
    set remaining_cities but-first remaining_cities
    set nn nn + (calculate_distance current_city closest_city)
    set current_city closest_city
  ]
  set nn nn + (calculate_distance start current_city)
end

to setup_edges
  let remaining_cities [self] of nodes
  while [not empty? remaining_cities] [
    let start first remaining_cities
    set remaining_cities but-first remaining_cities
    ask start [
      foreach remaining_cities [
        create-edge-with ? [
          set city_a start
          set city_b ?
          set cost ceiling calculate_distance start ?
          set pheromone ( 1 / ( 51 * nn )) 
        ]
      ]
    ]
  ]
  ask edges [ hide-link ]
end

;;; Display Functions
to show_pheromones
  if (show_pheromones?) [ set color yellow ]
end 

to show_cities
  if (is_city? and show_cities?) [ set pcolor green ]
end

;;; Path Functions
to-report get_random_path
  let path one-of nodes
  report fput path lput path [self] of nodes with [self != path ]
end

to-report get_tour_edges [tour_cities]
  let x but-last tour_cities
  let y but-first tour_cities
  let tour_edges []
  (foreach x y [ ask ?1 [ set tour_edges lput link-with ?2 tour_edges ] ])
  
  report tour_edges
end

to-report get_path
  let start one-of nodes
  let new_tour (list start)
  let remaining_cities [self] of nodes with [self != start]
  let current_city start
  
  while [not empty? remaining_cities] [
    let next_city choose_next_city current_city remaining_cities
    set new_tour lput next_city new_tour
    set remaining_cities remove next_city remaining_cities
    let current 0
    let next 0
    let newx 0
    let newy 0
    ask current_city [ set current who ]
    ask next_city [ 
      set next who
      set newx xcor
      set newy ycor 
    ]
    setxy newx newy
    ask edge current next [ set pheromone (1 - evaporation_rate) * ( pheromone + ( evaporation_rate * ( 1 / ( 51 * nn ) )) ) ]
    set current_city next_city
  ]

  report lput start new_tour
end

to-report has_candidate?
  ifelse ( cl <= 0 ) [ report false ]
                     [ report true ]
end

to-report has_max_candidate?
  if (not has_candidate? ) [ report false ] 
  
  let _q random-float 1
  
  ifelse ( _q <= qnot ) [ report true ]
                        [ report false ]
end

to-report choose_next_city [ current_city remaining_cities ]
  ifelse (not has_max_candidate?) [
    let p movement_probabilities current_city remaining_cities
    report choose_city p
  ]
  [
    report max_candidate current_city remaining_cities
  ]
end

to-report max_candidate [city remaining_cities]
  let current_edge 0
  let candidate_edges []
  ask city [
    set candidate_edges map [ edge_with? self ? ] filter [ member? ? candidate_list ] remaining_cities
    if not empty? candidate_edges [
      let v map [ (pheromone_of ?) * (cost_of ?) ^ beta ] candidate_edges
      set current_edge item position max v v candidate_edges
    ]
  ]
  
  ifelse current_edge = 0 [ report choose_next_city city remaining_cities ]
                          [ report get_destination city current_edge ]
end

to-report edge_with? [c1 c2]
  let ew 0
  ask c1 [
    set ew edge-with c2
  ]
  
  report ew
end

to-report get_destination [current_city current_edge]
  let destination 0
  ask current_edge [ ifelse (city_a = current_city) [ set destination city_b ]
                                                    [ set destination city_a ]
  ]
  
  report destination
end

to-report choose_city [probabilities]
  let probs filter [ first ? >= random-float 1 ] probabilities
  
  while [ empty? probs ] [
    set probs filter [ first ? >= random-float 1 ] probabilities
  ]
  
  report last first probs
end

to-report get_tour_length [cities]
  report reduce [?1 + ?2] map [ cost_of ? ] get_tour_edges cities
end

to-report cost_of [edge]
  report [cost] of edge
end

to-report calculate_distance [city_one city_two]
  let diffx ( xcor_of city_one ) - ( xcor_of city_two )
  let diffy ( ycor_of city_one ) - ( ycor_of city_two )
  report sqrt (diffx ^ 2 + diffy ^ 2)
end

to-report movement_probabilities [current_city remaining_cities]
  let probabilities []
  let c_sum 0
  
  foreach remaining_cities [
    ask current_city [
      let current_edge edge-with ?
      let probability ((pheromone_of current_edge) * (1 / (cost_of current_edge)) ^ beta)
      set probabilities lput (list probability ?) probabilities
      set c_sum (c_sum + probability)
    ]
  ]
  
  let p []
  foreach probabilities [
    set p lput (list (first ? / c_sum) last ?) p
  ]
  
  set p sort-by [ first ?1 < first ?2 ] p
  
  report p
end
  

to-report xcor_of [city]
  report [xcor] of city
end

to-report ycor_of [city]
  report [ycor] of city
end

to-report pheromone_of [edge]
  report [pheromone] of edge
end

;;;Update functions
to update_pheromone
  foreach get_tour_edges best_tour [
    ask ? [ set pheromone ((1 - evaporation_rate) * pheromone) + (evaporation_rate * ( Q / best_tour_cost )) ]
  ]
end

to find_best_tour
  ;; find the best tour
  ask ants [
    if (tour_cost < best_tour_cost) [
      set best_tour tour
      set best_tour_cost tour_cost
      update_best_tour
    ] 
  ]
end

to update_best_tour
  ask edges [ hide-link ]
  foreach get_tour_edges best_tour [
    ask ? [ show-link ]
    ask ? [ set color green ]
  ]
end
@#$#@#$#@
GRAPHICS-WINDOW
147
10
725
609
-1
-1
8.0
1
10
1
1
1
0
0
0
1
0
70
0
70
1
1
1
ticks
30.0

SLIDER
820
38
1010
71
evaporation_rate
evaporation_rate
0
1
0.1
0.1
1
NIL
HORIZONTAL

BUTTON
735
14
798
47
setup
setup
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

BUTTON
735
69
798
102
go
go
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

BUTTON
735
124
798
157
go
go
T
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

SLIDER
1309
46
1481
79
num_ants
num_ants
1
50
40
1
1
NIL
HORIZONTAL

TEXTBOX
826
19
976
37
Pheromone Settings
10
0.0
1

TEXTBOX
1366
18
1516
36
Ant Settings
11
0.0
1

SLIDER
1310
96
1482
129
n
n
0
100
2
1
1
NIL
HORIZONTAL

SLIDER
1310
148
1482
181
k
k
0
100
5
1
1
NIL
HORIZONTAL

BUTTON
736
176
799
209
clear
clear-all\nreset-ticks
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

SWITCH
1335
254
1469
287
show_cities?
show_cities?
0
1
-1000

SWITCH
1314
347
1479
380
show_pheromones?
show_pheromones?
1
1
-1000

TEXTBOX
1371
222
1521
240
Switches
11
0.0
1

SWITCH
1338
301
1459
334
show_nest?
show_nest?
1
1
-1000

TEXTBOX
56
21
206
39
LEGEND
14
0.0
1

TEXTBOX
36
52
186
70
RED dots = ants
14
15.0
1

TEXTBOX
12
112
219
146
YELLOW patches = pheromones
14
44.0
1

TEXTBOX
13
71
163
105
GREEN patches = cities\n
14
55.0
1

SLIDER
822
99
994
132
Q
Q
1
100
100
1
1
NIL
HORIZONTAL

TEXTBOX
828
77
978
95
Pheromone Additive Constant
10
0.0
1

SLIDER
826
152
998
185
alpha
alpha
0
2
0.2
0.1
1
NIL
HORIZONTAL

SLIDER
826
195
998
228
beta
beta
0
5
2
0.1
1
NIL
HORIZONTAL

MONITOR
827
241
931
286
Best Tour Cost
best_tour_cost
17
1
11

SLIDER
833
327
1005
360
cl
cl
0
50
15
1
1
NIL
HORIZONTAL

SLIDER
833
372
1005
405
qnot
qnot
0
1
0.9
0.1
1
NIL
HORIZONTAL

PLOT
281
738
786
1087
plot
NIL
NIL
0.0
10.0
0.0
10.0
true
false
"" ""
PENS
"default" 1.0 0 -16777216 true "" "plot best_tour_cost"
"pen-1" 1.0 0 -7500403 true "" ""

@#$#@#$#@
## WHAT IS IT?

(a general understanding of what the model is trying to show or explain)

## HOW IT WORKS

(what rules the agents use to create the overall behavior of the model)

## HOW TO USE IT

(how to use the model, including a description of each of the items in the Interface tab)

## THINGS TO NOTICE

(suggested things for the user to notice while running the model)

## THINGS TO TRY

(suggested things for the user to try to do (move sliders, switches, etc.) with the model)

## EXTENDING THE MODEL

(suggested things to add or change in the Code tab to make the model more complicated, detailed, accurate, etc.)

## NETLOGO FEATURES

(interesting or unusual features of NetLogo that the model uses, particularly in the Code tab; or where workarounds were needed for missing features)

## RELATED MODELS

(models in the NetLogo Models Library and elsewhere which are of related interest)

## CREDITS AND REFERENCES

(a reference to the model's URL on the web if it has one, as well as any other necessary credits, citations, and links)
@#$#@#$#@
default
true
0
Polygon -7500403 true true 150 5 40 250 150 205 260 250

airplane
true
0
Polygon -7500403 true true 150 0 135 15 120 60 120 105 15 165 15 195 120 180 135 240 105 270 120 285 150 270 180 285 210 270 165 240 180 180 285 195 285 165 180 105 180 60 165 15

arrow
true
0
Polygon -7500403 true true 150 0 0 150 105 150 105 293 195 293 195 150 300 150

box
false
0
Polygon -7500403 true true 150 285 285 225 285 75 150 135
Polygon -7500403 true true 150 135 15 75 150 15 285 75
Polygon -7500403 true true 15 75 15 225 150 285 150 135
Line -16777216 false 150 285 150 135
Line -16777216 false 150 135 15 75
Line -16777216 false 150 135 285 75

bug
true
0
Circle -7500403 true true 96 182 108
Circle -7500403 true true 110 127 80
Circle -7500403 true true 110 75 80
Line -7500403 true 150 100 80 30
Line -7500403 true 150 100 220 30

butterfly
true
0
Polygon -7500403 true true 150 165 209 199 225 225 225 255 195 270 165 255 150 240
Polygon -7500403 true true 150 165 89 198 75 225 75 255 105 270 135 255 150 240
Polygon -7500403 true true 139 148 100 105 55 90 25 90 10 105 10 135 25 180 40 195 85 194 139 163
Polygon -7500403 true true 162 150 200 105 245 90 275 90 290 105 290 135 275 180 260 195 215 195 162 165
Polygon -16777216 true false 150 255 135 225 120 150 135 120 150 105 165 120 180 150 165 225
Circle -16777216 true false 135 90 30
Line -16777216 false 150 105 195 60
Line -16777216 false 150 105 105 60

car
false
0
Polygon -7500403 true true 300 180 279 164 261 144 240 135 226 132 213 106 203 84 185 63 159 50 135 50 75 60 0 150 0 165 0 225 300 225 300 180
Circle -16777216 true false 180 180 90
Circle -16777216 true false 30 180 90
Polygon -16777216 true false 162 80 132 78 134 135 209 135 194 105 189 96 180 89
Circle -7500403 true true 47 195 58
Circle -7500403 true true 195 195 58

circle
false
0
Circle -7500403 true true 0 0 300

circle 2
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240

cow
false
0
Polygon -7500403 true true 200 193 197 249 179 249 177 196 166 187 140 189 93 191 78 179 72 211 49 209 48 181 37 149 25 120 25 89 45 72 103 84 179 75 198 76 252 64 272 81 293 103 285 121 255 121 242 118 224 167
Polygon -7500403 true true 73 210 86 251 62 249 48 208
Polygon -7500403 true true 25 114 16 195 9 204 23 213 25 200 39 123

cylinder
false
0
Circle -7500403 true true 0 0 300

dot
false
0
Circle -7500403 true true 90 90 120

face happy
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 255 90 239 62 213 47 191 67 179 90 203 109 218 150 225 192 218 210 203 227 181 251 194 236 217 212 240

face neutral
false
0
Circle -7500403 true true 8 7 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Rectangle -16777216 true false 60 195 240 225

face sad
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 168 90 184 62 210 47 232 67 244 90 220 109 205 150 198 192 205 210 220 227 242 251 229 236 206 212 183

fish
false
0
Polygon -1 true false 44 131 21 87 15 86 0 120 15 150 0 180 13 214 20 212 45 166
Polygon -1 true false 135 195 119 235 95 218 76 210 46 204 60 165
Polygon -1 true false 75 45 83 77 71 103 86 114 166 78 135 60
Polygon -7500403 true true 30 136 151 77 226 81 280 119 292 146 292 160 287 170 270 195 195 210 151 212 30 166
Circle -16777216 true false 215 106 30

flag
false
0
Rectangle -7500403 true true 60 15 75 300
Polygon -7500403 true true 90 150 270 90 90 30
Line -7500403 true 75 135 90 135
Line -7500403 true 75 45 90 45

flower
false
0
Polygon -10899396 true false 135 120 165 165 180 210 180 240 150 300 165 300 195 240 195 195 165 135
Circle -7500403 true true 85 132 38
Circle -7500403 true true 130 147 38
Circle -7500403 true true 192 85 38
Circle -7500403 true true 85 40 38
Circle -7500403 true true 177 40 38
Circle -7500403 true true 177 132 38
Circle -7500403 true true 70 85 38
Circle -7500403 true true 130 25 38
Circle -7500403 true true 96 51 108
Circle -16777216 true false 113 68 74
Polygon -10899396 true false 189 233 219 188 249 173 279 188 234 218
Polygon -10899396 true false 180 255 150 210 105 210 75 240 135 240

house
false
0
Rectangle -7500403 true true 45 120 255 285
Rectangle -16777216 true false 120 210 180 285
Polygon -7500403 true true 15 120 150 15 285 120
Line -16777216 false 30 120 270 120

leaf
false
0
Polygon -7500403 true true 150 210 135 195 120 210 60 210 30 195 60 180 60 165 15 135 30 120 15 105 40 104 45 90 60 90 90 105 105 120 120 120 105 60 120 60 135 30 150 15 165 30 180 60 195 60 180 120 195 120 210 105 240 90 255 90 263 104 285 105 270 120 285 135 240 165 240 180 270 195 240 210 180 210 165 195
Polygon -7500403 true true 135 195 135 240 120 255 105 255 105 285 135 285 165 240 165 195

line
true
0
Line -7500403 true 150 0 150 300

line half
true
0
Line -7500403 true 150 0 150 150

pentagon
false
0
Polygon -7500403 true true 150 15 15 120 60 285 240 285 285 120

person
false
0
Circle -7500403 true true 110 5 80
Polygon -7500403 true true 105 90 120 195 90 285 105 300 135 300 150 225 165 300 195 300 210 285 180 195 195 90
Rectangle -7500403 true true 127 79 172 94
Polygon -7500403 true true 195 90 240 150 225 180 165 105
Polygon -7500403 true true 105 90 60 150 75 180 135 105

plant
false
0
Rectangle -7500403 true true 135 90 165 300
Polygon -7500403 true true 135 255 90 210 45 195 75 255 135 285
Polygon -7500403 true true 165 255 210 210 255 195 225 255 165 285
Polygon -7500403 true true 135 180 90 135 45 120 75 180 135 210
Polygon -7500403 true true 165 180 165 210 225 180 255 120 210 135
Polygon -7500403 true true 135 105 90 60 45 45 75 105 135 135
Polygon -7500403 true true 165 105 165 135 225 105 255 45 210 60
Polygon -7500403 true true 135 90 120 45 150 15 180 45 165 90

sheep
false
15
Circle -1 true true 203 65 88
Circle -1 true true 70 65 162
Circle -1 true true 150 105 120
Polygon -7500403 true false 218 120 240 165 255 165 278 120
Circle -7500403 true false 214 72 67
Rectangle -1 true true 164 223 179 298
Polygon -1 true true 45 285 30 285 30 240 15 195 45 210
Circle -1 true true 3 83 150
Rectangle -1 true true 65 221 80 296
Polygon -1 true true 195 285 210 285 210 240 240 210 195 210
Polygon -7500403 true false 276 85 285 105 302 99 294 83
Polygon -7500403 true false 219 85 210 105 193 99 201 83

square
false
0
Rectangle -7500403 true true 30 30 270 270

square 2
false
0
Rectangle -7500403 true true 30 30 270 270
Rectangle -16777216 true false 60 60 240 240

star
false
0
Polygon -7500403 true true 151 1 185 108 298 108 207 175 242 282 151 216 59 282 94 175 3 108 116 108

target
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240
Circle -7500403 true true 60 60 180
Circle -16777216 true false 90 90 120
Circle -7500403 true true 120 120 60

tree
false
0
Circle -7500403 true true 118 3 94
Rectangle -6459832 true false 120 195 180 300
Circle -7500403 true true 65 21 108
Circle -7500403 true true 116 41 127
Circle -7500403 true true 45 90 120
Circle -7500403 true true 104 74 152

triangle
false
0
Polygon -7500403 true true 150 30 15 255 285 255

triangle 2
false
0
Polygon -7500403 true true 150 30 15 255 285 255
Polygon -16777216 true false 151 99 225 223 75 224

truck
false
0
Rectangle -7500403 true true 4 45 195 187
Polygon -7500403 true true 296 193 296 150 259 134 244 104 208 104 207 194
Rectangle -1 true false 195 60 195 105
Polygon -16777216 true false 238 112 252 141 219 141 218 112
Circle -16777216 true false 234 174 42
Rectangle -7500403 true true 181 185 214 194
Circle -16777216 true false 144 174 42
Circle -16777216 true false 24 174 42
Circle -7500403 false true 24 174 42
Circle -7500403 false true 144 174 42
Circle -7500403 false true 234 174 42

turtle
true
0
Polygon -10899396 true false 215 204 240 233 246 254 228 266 215 252 193 210
Polygon -10899396 true false 195 90 225 75 245 75 260 89 269 108 261 124 240 105 225 105 210 105
Polygon -10899396 true false 105 90 75 75 55 75 40 89 31 108 39 124 60 105 75 105 90 105
Polygon -10899396 true false 132 85 134 64 107 51 108 17 150 2 192 18 192 52 169 65 172 87
Polygon -10899396 true false 85 204 60 233 54 254 72 266 85 252 107 210
Polygon -7500403 true true 119 75 179 75 209 101 224 135 220 225 175 261 128 261 81 224 74 135 88 99

wheel
false
0
Circle -7500403 true true 3 3 294
Circle -16777216 true false 30 30 240
Line -7500403 true 150 285 150 15
Line -7500403 true 15 150 285 150
Circle -7500403 true true 120 120 60
Line -7500403 true 216 40 79 269
Line -7500403 true 40 84 269 221
Line -7500403 true 40 216 269 79
Line -7500403 true 84 40 221 269

wolf
false
0
Polygon -16777216 true false 253 133 245 131 245 133
Polygon -7500403 true true 2 194 13 197 30 191 38 193 38 205 20 226 20 257 27 265 38 266 40 260 31 253 31 230 60 206 68 198 75 209 66 228 65 243 82 261 84 268 100 267 103 261 77 239 79 231 100 207 98 196 119 201 143 202 160 195 166 210 172 213 173 238 167 251 160 248 154 265 169 264 178 247 186 240 198 260 200 271 217 271 219 262 207 258 195 230 192 198 210 184 227 164 242 144 259 145 284 151 277 141 293 140 299 134 297 127 273 119 270 105
Polygon -7500403 true true -1 195 14 180 36 166 40 153 53 140 82 131 134 133 159 126 188 115 227 108 236 102 238 98 268 86 269 92 281 87 269 103 269 113

x
false
0
Polygon -7500403 true true 270 75 225 30 30 225 75 270
Polygon -7500403 true true 30 75 75 30 270 225 225 270

@#$#@#$#@
NetLogo 5.1.0
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
default
0.0
-0.2 0 0.0 1.0
0.0 1 1.0 0.0
0.2 0 0.0 1.0
link direction
true
0
Line -7500403 true 150 150 90 180
Line -7500403 true 150 150 210 180

@#$#@#$#@
0
@#$#@#$#@
