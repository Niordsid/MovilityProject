extensions [gis]
breed [poli-labels poli-label]
breed [coches coche]
breed [buses bus]
breed [camiones camion]
breed [semaforos semaforo]

buses-own
[
  speed         ;; the current speed of the car
  speed-limit   ;; the maximum speed of the car (different for all cars)
  speed-min
  lane          ;; the current lane of the car
  target-lane   ;; the desired lane of the car
  patience      ;; the driver's current patience
  max-patience  ;; the driver's maximum patience
  change?       ;; true if the car wants to change lanes
]

camiones-own
[
  speed         ;; the current speed of the car
  speed-limit   ;; the maximum speed of the car (different for all cars)
  speed-min
  lane          ;; the current lane of the car
  target-lane   ;; the desired lane of the car
  patience      ;; the driver's current patience
  max-patience  ;; the driver's maximum patience
  change?       ;; true if the car wants to change lanes
]

coches-own
[
  speed         ;; the current speed of the car
  speed-limit   ;; the maximum speed of the car (different for all cars)
  speed-min
  lane          ;; the current lane of the car
  target-lane   ;; the desired lane of the car
  patience      ;; the driver's current patience
  max-patience  ;; the driver's maximum patience
  change?       ;; true if the car wants to change lanes
]




;;Declaración de variable globales
Globals
[
  num-individuos    ;;número de individuos total que se encontraran en el modelo
  num-vehiculos     ;;número de vehiculos total presentes en el modelo incluyendo carros, buses y camiones
  num-infractores   ;;número total de infractores que vamos a encontrar a lo largo del tramo

  estado-clima      ;;variable que nos permitira identificar el tipo de clima encontrado en la zona (soleado "0" o lluvioso "1")

  ;;variables del parche
  cont_indv_bogota    ;;conteo número de individuos presentes en la ciudad de Bogota
  cont_indv_mosquera  ;;conteo número de individuos presentes en el municipio de Mosquera
  cont_indv_desv      ;;conteo número de individuos que se perdieron del sistema a través de las interssecciones

; Semaforos

  current-light
  ticks-at-last-change

  ;;necesarias para el shapefile

  vias
  poli
  separador
  semaforo
  paradero
  tickss

  ;;variables vehicular

]

;;Declaración de patches
patches-own
[
  intersection?   ;; true if the patch is at the intersection of two roads
  green-light-up? ;;patches de los semaforos presentes en el tramo  -  número de semaforos
  peaje     ;;peajes existentes en el recorrido - número de peajes
  paradas   ;;estaciones o paradas de los buses - número de paradas en el tramo de la vía
]


;;;DESARROLLO DEL PROGRAMA

;-------------------Declaracion de los Semaforos--------------------------------
to setup-semaforos

  ask patch 44 47 [ sprout-semaforos 1 [ set color green ] ]
  ask patch 44 48 [ sprout-semaforos 1 [ set color green ] ]
  ask patch 44 49 [ sprout-semaforos 1 [ set color green ] ]
  ask patch 44 51 [ sprout-semaforos 1 [ set color green ] ]
  ask patch 44 52 [ sprout-semaforos 1 [ set color green ] ]
  ask patch 44 53 [ sprout-semaforos 1 [ set color green ] ]

  ask patch 66 47 [ sprout-semaforos 1 [ set color green ] ]
  ask patch 66 48 [ sprout-semaforos 1 [ set color green ] ]
  ask patch 66 49 [ sprout-semaforos 1 [ set color green ] ]
  ask patch 66 51 [ sprout-semaforos 1 [ set color green ] ]
  ask patch 66 52 [ sprout-semaforos 1 [ set color green ] ]
  ask patch 66 53 [ sprout-semaforos 1 [ set color green ] ]

  ask patch 84 47 [ sprout-semaforos 1 [ set color green ] ]
  ask patch 84 48 [ sprout-semaforos 1 [ set color green ] ]
  ask patch 84 49 [ sprout-semaforos 1 [ set color green ] ]
  ask patch 84 51 [ sprout-semaforos 1 [ set color green ] ]
  ask patch 84 52 [ sprout-semaforos 1 [ set color green ] ]
  ask patch 84 53 [ sprout-semaforos 1 [ set color green ] ]

  ask patch 107 47 [ sprout-semaforos 1 [ set color green ] ]
  ask patch 107 48 [ sprout-semaforos 1 [ set color green ] ]
  ask patch 107 49 [ sprout-semaforos 1 [ set color green ] ]
  ask patch 107 51 [ sprout-semaforos 1 [ set color green ] ]
  ask patch 107 52 [ sprout-semaforos 1 [ set color green ] ]
  ask patch 107 53 [ sprout-semaforos 1 [ set color green ] ]

  ask patch 122 47 [ sprout-semaforos 1 [ set color green ] ]
  ask patch 122 48 [ sprout-semaforos 1 [ set color green ] ]
  ask patch 122 49 [ sprout-semaforos 1 [ set color green ] ]
  ask patch 122 51 [ sprout-semaforos 1 [ set color green ] ]
  ask patch 122 52 [ sprout-semaforos 1 [ set color green ] ]
  ask patch 122 53 [ sprout-semaforos 1 [ set color green ] ]

  ask patch 160 47 [ sprout-semaforos 1 [ set color green ] ]
  ask patch 160 48 [ sprout-semaforos 1 [ set color green ] ]
  ask patch 160 49 [ sprout-semaforos 1 [ set color green ] ]
  ask patch 160 51 [ sprout-semaforos 1 [ set color green ] ]
  ask patch 160 52 [ sprout-semaforos 1 [ set color green ] ]
  ask patch 160 53 [ sprout-semaforos 1 [ set color green ] ]

  ask patch 188 47 [ sprout-semaforos 1 [ set color green ] ]
  ask patch 188 48 [ sprout-semaforos 1 [ set color green ] ]
  ask patch 188 49 [ sprout-semaforos 1 [ set color green ] ]
  ask patch 188 51 [ sprout-semaforos 1 [ set color green ] ]
  ask patch 188 52 [ sprout-semaforos 1 [ set color green ] ]
  ask patch 188 53 [ sprout-semaforos 1 [ set color green ] ]
  ;----------------------------------------------------------
end


;--------------------- Creacion del Mundo y de los Agentes presentes (Autos , Semaforos)
to setup
  clear-all

  import-pcolors-rgb "Via.jpg"

  set-default-shape semaforos "circle"
  setup-semaforos
  set-default-shape coches "car"
  set-default-shape buses "bus"
  set-default-shape camiones "truck"



  create-coches Num_Coches [

    set size 1
    set color sky
    set heading 90
    setxy (random 200)  random (53 - 48) + 48

   ; set lane (random 2)
   ; set target-lane lane
     ]

  create-buses Num_Buses [
    set size 1
    set color red - 1
    set heading 90
    setxy (random 200)  47
   ; set lane (random 2)
   ; set target-lane lane

    ]
  create-camiones Num_Camiones [
    set size 1
    set color magenta - 1
    set heading 90
    setxy (random 200)  random (53 - 48) + 48
   ; set lane (random 2)
   ; set target-lane lane
     ]

  reset-ticks
end

to random-zone

  let saberzona random 2

  ifelse (saberzona = 0) [
    setxy (random 200) random (53 - 51) + 51
    ]

  [if (saberzona = 1) [
  setxy (random 200) random (49 - 47) + 47
       ]
   ]

end

to setup-cars1




  ifelse (lane = 0) [
    setxy random-xcor 48
  ]
  [
    setxy random-xcor 52
  ]

  set speed 0.1 + random 9.9
  set speed-limit (((random 11) / 10) + 1)
  set change? false
  set max-patience ((random 50) + 10)
  set patience (max-patience - (random 10))

  ;; make sure no two cars are on the same patch
  loop [
    ifelse any? other turtles-here [ fd 1 ] [ stop ]
  ]
end

to setup-cars2
  set size 1.5 set shape "car"   set heading 90
  set lane (random 2)
  set target-lane lane
  ifelse (lane = 0) [
    setxy random-xcor 48
  ]
  [
    setxy random-xcor 52
  ]
  set heading 90
  set speed 0.1 + random 9.9
  set speed-limit (((random 11) / 10) + 1)
  set change? false
  set max-patience ((random 50) + 10)
  set patience (max-patience - (random 10))

  ;; make sure no two cars are on the same patch
  loop [
    ifelse any? other turtles-here [ fd 1 ] [ stop ]
  ]
end

to setup-cars3
  set size 1.5 set shape "car"   set heading 90
  set lane (random 2)
  set target-lane lane
  ifelse (lane = 0) [
    setxy random-xcor 48
  ]
  [
    setxy random-xcor 52
  ]
  set heading 90
  set speed 0.1 + random 9.9
  set speed-limit (((random 11) / 10) + 1)
  set change? false
  set max-patience ((random 50) + 10)
  set patience (max-patience - (random 10))

  ;; make sure no two cars are on the same patch
  loop [
    ifelse any? other turtles-here [ fd 1 ] [ stop ]
  ]
end

to go
   move-turtles
   change-to-red
   drive
   ; para semaforo if (light-color = red) [stop-car]
  reset-ticks
end

to move-turtles
  ask turtles [
    if (pcolor = white) or ( pcolor = 104.9) or ( pcolor = 65) or ( pcolor = 13.5) or ( pcolor = 4.6) [
  fd 1
    ]
  if (pcolor = black)[
    stop
    ]
    ]
  tick
end

to separate-cars ;; turtle procedure
  if any? other turtles-here [
    fd 1
    separate-cars
  ]
end

;; turtle (car) procedure
to slow-down-car [ car-ahead ]
  ;; slow down so you are driving more slowly than the car ahead of you
  set speed [ speed ] of car-ahead - deceleration
end

;; turtle (car) procedure
to speed-up-car
  set speed speed + acceleration
end







to homogeneizar

  ;;corrección zonas exteriores
  ask patches with [pcolor = 1] [set pcolor 0]
  ask patches with [pcolor = 130.8] [set pcolor 0]
  ask patches with [pcolor = 1.8] [set pcolor 0]
  ask patches with [pcolor = 2.2] [set pcolor 0]
  ask patches with [pcolor = 131.9] [set pcolor 0]
  ask patches with [pcolor = 1.1] [set pcolor 0]
  ask patches with [pcolor = 3.8] [set pcolor 0]
  ask patches with [pcolor = 12.9] [set pcolor 0]
  ;;corrección zonas rojas
  ask patches with [pcolor = 12] [set pcolor 13.5]
  ask patches with [pcolor = 12.2] [set pcolor 13.5]
  ask patches with [pcolor = 12.1] [set pcolor 13.5]
  ask patches with [pcolor = 3.2] [set pcolor 13.5]
  ask patches with [pcolor = 13] [set pcolor 13.5]
  ask patches with [pcolor = 11.2] [set pcolor 13.5]
  ask patches with [pcolor = 133.3] [set pcolor 13.5]
  ask patches with [pcolor = 12.8] [set pcolor 13.5]
  ask patches with [pcolor = 133] [set pcolor 13.5]
  ask patches with [pcolor = 13.3] [set pcolor 13.5]
  ask patches with [pcolor = 3.9] [set pcolor 13.5]
  ask patches with [pcolor = 1.2] [set pcolor 13.5]
  ask patches with [pcolor = 133.2] [set pcolor 13.5]
  ask patches with [pcolor = 132.8] [set pcolor 13.5]
  ask patches with [pcolor = 12.7] [set pcolor 13.5]
  ask patches with [pcolor = 12.9] [set pcolor 13.5]
  ask patches with [pcolor = 13.1] [set pcolor 13.5]
  ask patches with [pcolor = 133.1] [set pcolor 13.5]
  ask patches with [pcolor = 133.4] [set pcolor 13.5]
  ask patches with [pcolor = 1.5] [set pcolor 13.5]
  ask patches with [pcolor = 3.7] [set pcolor 13.5]
  ask patches with [pcolor = 132.7] [set pcolor 13.5]
  ask patches with [pcolor = 3.3] [set pcolor 13.5]
  ask patches with [pcolor = 12.6] [set pcolor 13.5]
  ask patches with [pcolor = 130.4] [set pcolor 13.5]
  ask patches with [pcolor = 132.6] [set pcolor 13.5]
  ask patches with [pcolor = 132.9] [set pcolor 13.5]
  ask patches with [pcolor = 13.7] [set pcolor 13.5]
  ask patches with [pcolor = 2.7] [set pcolor 13.5]
  ask patches with [pcolor = 13.2] [set pcolor 13.5]
  ;;corrección vias
  ask patches with [pcolor = 44.4] [set pcolor 9.9]
  ask patches with [pcolor = 89.6] [set pcolor 9.9]
  ask patches with [pcolor = 49.1] [set pcolor 9.9]
  ask patches with [pcolor = 49] [set pcolor 9.9]
  ask patches with [pcolor = 3] [set pcolor 9.9]
  ask patches with [pcolor = 2.9] [set pcolor 9.9]
  ask patches with [pcolor = 8.1] [set pcolor 9.9]
  ask patches with [pcolor = 6] [set pcolor 9.9]
  ask patches with [pcolor = 8] [set pcolor 9.9]
  ask patches with [pcolor = 5.9] [set pcolor 9.9]
  ask patches with [pcolor = 8.7] [set pcolor 9.9]
  ask patches with [pcolor = 1.1] [set pcolor 9.9]
  ask patches with [pcolor = 6.6] [set pcolor 9.9]
  ask patches with [pcolor = 0.8] [set pcolor 9.9]
  ask patches with [pcolor = 8.8] [set pcolor 9.9]
  ask patches with [pcolor = 8.4] [set pcolor 9.9]
  ask patches with [pcolor = 7] [set pcolor 9.9]
  ask patches with [pcolor = 9] [set pcolor 9.9]
  ask patches with [pcolor = 8.9] [set pcolor 9.9]
  ask patches with [pcolor = 49.5] [set pcolor 9.9]
  ask patches with [pcolor = 9.4] [set pcolor 9.9]
  ask patches with [pcolor = 49.3] [set pcolor 9.9]
  ask patches with [pcolor = 6.2] [set pcolor 9.9]
  ask patches with [pcolor = 49.4] [set pcolor 9.9]
  ask patches with [pcolor = 49.2] [set pcolor 9.9]
  ask patches with [pcolor = 48.7] [set pcolor 9.9]
  ask patches with [pcolor = 9.5] [set pcolor 9.9]
  ask patches with [pcolor = 1.9] [set pcolor 9.9]
  ask patches with [pcolor = 5.6] [set pcolor 9.9]
  ask patches with [pcolor = 7.2] [set pcolor 9.9]
  ask patches with [pcolor = 4.4] [set pcolor 9.9]
  ask patches with [pcolor = 9.3] [set pcolor 9.9]
  ask patches with [pcolor = 1.3] [set pcolor 9.9]
  ask patches with [pcolor = 3.5] [set pcolor 9.9]
  ask patches with [pcolor = 49] [set pcolor 9.9]
  ask patches with [pcolor = 49.6] [set pcolor 9.9]
  ask patches with [pcolor = 6.7] [set pcolor 9.9]
  ask patches with [pcolor = 5.5] [set pcolor 9.9]
  ask patches with [pcolor = 6.9] [set pcolor 9.9]
  ask patches with [pcolor = 69.3] [set pcolor 9.9]
  ask patches with [pcolor = 9.6] [set pcolor 9.9]
  ask patches with [pcolor = 0.7] [set pcolor 9.9]
  ;;corrección paraderos
  ask patches with [pcolor = 97.6] [set pcolor 104.9]
  ask patches with [pcolor = 106.2] [set pcolor 104.9]
  ask patches with [pcolor = 89.4] [set pcolor 104.9]
  ask patches with [pcolor = 94.9] [set pcolor 104.9]
  ask patches with [pcolor = 89.3] [set pcolor 104.9]
  ask patches with [pcolor = 97.1] [set pcolor 104.9]
  ask patches with [pcolor = 106.4] [set pcolor 104.9]
  ask patches with [pcolor = 106.9] [set pcolor 104.9]
  ask patches with [pcolor = 97.9] [set pcolor 104.9]
  ask patches with [pcolor = 89.5] [set pcolor 104.9]
  ask patches with [pcolor = 89.2] [set pcolor 104.9]
  ask patches with [pcolor = 107.7] [set pcolor 104.9]
  ;;corrección separadores
  ask patches with [pcolor = 9.2] [set pcolor 4.6]
  ask patches with [pcolor = 6.4] [set pcolor 4.6]
  ask patches with [pcolor = 6.5] [set pcolor 4.6]
  ask patches with [pcolor = 8.5] [set pcolor 4.6]
  ask patches with [pcolor = 6.8] [set pcolor 4.6]
  ask patches with [pcolor = 5.1] [set pcolor 4.6]
  ask patches with [pcolor = 8.2] [set pcolor 4.6]
  ask patches with [pcolor = 5.3] [set pcolor 4.6]
  ask patches with [pcolor = 4.9] [set pcolor 4.6]
  ask patches with [pcolor = 6.8] [set pcolor 4.6]
  ask patches with [pcolor = 5.2] [set pcolor 4.6]
  ask patches with [pcolor = 5.4] [set pcolor 4.6]
  ask patches with [pcolor = 6.3] [set pcolor 4.6]
  ask patches with [pcolor = 98] [set pcolor 4.6]
  ;;Corrección semaforos
  ask patches with [pcolor = 44] [set pcolor 65]
  ask patches with [pcolor = 44.5] [set pcolor 65]
  ask patches with [pcolor = 44.1] [set pcolor 65]
  ask patches with [pcolor = 44.3] [set pcolor 65]
  ask patches with [pcolor = 46.9] [set pcolor 65]
  ask patches with [pcolor = 45.7] [set pcolor 65]
  ask patches with [pcolor = 46] [set pcolor 65]
  ask patches with [pcolor = 55.7] [set pcolor 65]
  ask patches with [pcolor = 46.6] [set pcolor 65]
  ask patches with [pcolor = 44.2] [set pcolor 65]
  ask patches with [pcolor = 48.1] [set pcolor 65]
  ask patches with [pcolor = 54.6] [set pcolor 65]
  ask patches with [pcolor = 51] [set pcolor 65]
  ask patches with [pcolor = 44] [set pcolor 65]
  ask patches with [pcolor = 52.1] [set pcolor 65]
  ask patches with [pcolor = 52.6] [set pcolor 65]
  ask patches with [pcolor = 42.8] [set pcolor 65]
  ask patches with [pcolor = 57] [set pcolor 65]
  ask patches with [pcolor = 55.9] [set pcolor 65]
  ask patches with [pcolor = 43.9] [set pcolor 65]

end

;; Creación de las tortugas a manejar en el modelo
;to create

  ;;inicializacion de la tortuga
  ;clear-turtles clear-all-plots
  ;set carros (Num_vehiculos * 0.60)
  ;set buses (Num_vehiculos * 0.30)
  ;set camiones (Num_vehiculos * 0.10)
  ;set num-individuos random 1120

  ;crt carros [ setxy xcor 24 + random 5 setxy ycor 53 + random 5 set size 1 set shape "car"  set color 26 set heading 90 ]
  ;crt buses [ setxy xcor 24 + random 5 setxy ycor 53 + random 5 set size 1 set shape "car"  set color 45  set heading 90]
  ;crt camiones [ setxy xcor 24 + random 5 setxy ycor 53 + random 5 set size 1 set shape "car"  set color 117 set heading 90 ]

;end


;;;;;; 2 lineas trafico

to drive
  ask turtles [
    ifelse (any? turtles-at 1 0) [
      set speed ([speed] of (one-of (turtles-at 1 0)))
      decelerate
    ]
    [
      ifelse (look-ahead = 2) [
        ifelse (any? turtles-at 2 0) [
          set speed ([speed] of (one-of turtles-at 2 0))
          decelerate
        ]
        [
          accelerate
        ]
      ]
      [
        accelerate
      ]
    ]
    if (speed < 0.01) [ set speed 0.01 ]
    if (speed > speed-limit) [ set speed speed-limit ]
  ]
  ; Now that all speeds are adjusted, give turtles a chance to change lanes
  ask turtles [
    ifelse (change? = false) [ signal ] [ change-lanes ]
    ;; Control for making sure no one crashes.
    ifelse (any? turtles-at 1 0) and (xcor != min-pxcor - .5) [
      set speed [speed] of (one-of turtles-at 1 0)
    ]
    [
      ifelse ((any? turtles-at 2 0) and (speed > 1.0)) [
        set speed ([speed] of (one-of turtles-at 2 0))
        fd 1
      ]
      [
        jump speed
      ]
    ]
  ]
  tick
end

;; increase speed of cars
to accelerate  ;; turtle procedure
  set speed (speed + (acceleration / 1000))
end

;; reduce speed of cars
to decelerate  ;; turtle procedure
  set speed (speed - (deceleration / 1000))
end

;; undergoes search algorithms
to change-lanes  ;; turtle procedure
  ifelse (patience <= 0) [
    ifelse (max-patience <= 1) [
      set max-patience (random 10) + 1
    ]
    [
      set max-patience (max-patience - (random 5))
    ]
    set patience max-patience
    ifelse (target-lane = 0) [
      set target-lane 1
      set lane 0
    ]
    [
      set target-lane 0
      set lane 1
    ]
  ]
  [
    set patience (patience - 1)
  ]
  ifelse (target-lane = lane) [
    ifelse (target-lane = 0) [
      set target-lane 1
      set change? false
    ]
    [
      set target-lane 0
      set change? false
    ]
  ]
  [
    ifelse (target-lane = 1) [
      ifelse (pycor = 2) [
        set lane 1
        set change? false
      ]
      [
        ifelse (not any? turtles-at 0 1) [
          set ycor (ycor + 1)
        ]
        [
          ifelse (not any? turtles-at 1 0) [
            set xcor (xcor + 1)
          ]
          [
            decelerate
            if (speed <= 0) [ set speed 0.1 ]
          ]
        ]
      ]
    ]
    [
      ifelse (pycor = -2) [
        set lane 0
        set change? false
      ]
      [
        ifelse (not any? turtles-at 0 -1) [
          set ycor (ycor - 1)
        ]
        [
          ifelse (not any? turtles-at 1 0) [
            set xcor (xcor + 1)
          ]
          [
            decelerate
            if (speed <= 0) [ set speed 0.1 ]
          ]
        ]
      ]
    ]
  ]
end

to signal
  ifelse (any? turtles-at 1 0) [
    if ([speed] of (one-of (turtles-at 1 0))) < (speed) [
      set change? true
    ]
  ]
  [
    set change? false
  ]
end



;;;;;;;;;; Semaforos


;semaforos

to change-to-red
  ask semaforos with [ color = 65 ] [
    set color red
    ask other semaforos [ set color 65 ]
    set ticks-at-last-change ticks
  ]
end

to change-current
  ask current-light
  [
    set green-light-up? (not green-light-up?)
    set-signal-colors
  ]
end

to set-signal-colors  ;; intersection (patch) procedure
  ifelse power?
  [
    ifelse green-light-up?
    [
      ask patch-at -1 0 [ set pcolor red ]
      ask patch-at 0 1 [ set pcolor 65 ]
    ]
    [
      ask patch-at -1 0 [ set pcolor 65 ]
      ask patch-at 0 1 [ set pcolor red ]
    ]
  ]
  [
    ask patch-at -1 0 [ set pcolor white ]
    ask patch-at 0 1 [ set pcolor white ]
  ]
end
@#$#@#$#@
GRAPHICS-WINDOW
558
10
1866
693
-1
-1
6.46
1
10
1
1
1
0
1
1
1
0
200
0
100
0
0
1
ticks
30.0

BUTTON
18
20
192
60
NIL
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

SLIDER
18
77
190
110
Num_Coches
Num_Coches
0
25
9
1
1
NIL
HORIZONTAL

BUTTON
85
446
194
479
NIL
homogeneizar
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

SLIDER
249
79
421
112
Num_inividuos
Num_inividuos
0
500
0
1
1
NIL
HORIZONTAL

SLIDER
250
148
422
181
acceleration
acceleration
0
1
0
0.01
1
NIL
HORIZONTAL

SLIDER
249
113
421
146
deceleration
deceleration
0
100
0
1
1
NIL
HORIZONTAL

SLIDER
248
12
420
45
look-ahead
look-ahead
1
2
1
1
1
NIL
HORIZONTAL

BUTTON
347
422
410
455
NIL
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

SWITCH
450
10
553
43
power?
power?
1
1
-1000

SLIDER
18
119
190
152
Num_Buses
Num_Buses
0
25
9
1
1
NIL
HORIZONTAL

SLIDER
18
161
190
194
Num_Camiones
Num_Camiones
0
25
9
1
1
NIL
HORIZONTAL

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

bus
false
0
Polygon -7500403 true true 15 206 15 150 15 120 30 105 270 105 285 120 285 135 285 206 270 210 30 210
Rectangle -16777216 true false 36 126 231 159
Line -7500403 true 60 135 60 165
Line -7500403 true 60 120 60 165
Line -7500403 true 90 120 90 165
Line -7500403 true 120 120 120 165
Line -7500403 true 150 120 150 165
Line -7500403 true 180 120 180 165
Line -7500403 true 210 120 210 165
Line -7500403 true 240 135 240 165
Rectangle -16777216 true false 15 174 285 182
Circle -16777216 true false 48 187 42
Rectangle -16777216 true false 240 127 276 205
Circle -16777216 true false 195 187 42
Line -7500403 true 257 120 257 207

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

van side
false
0
Polygon -7500403 true true 26 147 18 125 36 61 161 61 177 67 195 90 242 97 262 110 273 129 260 149
Circle -16777216 true false 43 123 42
Circle -16777216 true false 194 124 42
Polygon -16777216 true false 45 68 37 95 183 96 169 69
Line -7500403 true 62 65 62 103
Line -7500403 true 115 68 120 100
Polygon -1 true false 271 127 258 126 257 114 261 109
Rectangle -16777216 true false 19 131 27 142

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
NetLogo 5.3.1
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
