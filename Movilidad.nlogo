extensions [gis]
breed [coches coche]
breed [buses bus]
breed [camiones camion]
breed [semaforos semaforo]
breed [inmoviles inmovil]

turtles-own [
  car?
  speed
  speed-limit   ;; the maximum speed of the car (different for all cars)
  speed-min
  lane          ;; the current lane of the car
  target-lane   ;; the desired lane of the car
  patience      ;; the driver's current patience
  max-patience  ;; the driver's maximum patience
  change?
  parar?
  ]

buses-own [
  numero-pasajeros
  ]

semaforos-own[
  sensor1?
  from
  Xcord
  Ycord
  ]
;;Declaración de variable globales
Globals
[
  num-individuos    ;;número de individuos total que se encontraran en el modelo
  num-vehiculos     ;;número de vehiculos total presentes en el modelo incluyendo carros, buses y camiones

  estado-clima      ;;variable que nos permitira identificar el tipo de clima encontrado en la zona (soleado "0" o lluvioso "1")
  dias-lluviosos
  dias-buenclima

  ;;variables del parche
  cont_indv_bogota_recogidos    ;;conteo número de individuos presentes en la ciudad de Bogota
  cont_indv_bogota_dejados
  cont_indv_mosquera_recogidos  ;;conteo número de individuos presentes en el municipio de Mosquera
  cont_indv_mosquera_dejados
  cont_indv_desv      ;;conteo número de individuos que se perdieron del sistema a través de las interssecciones

  ;;necesarias para el shapefile

  vias
  poli
  separador
  semaforo
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
;-------------------------------Sensores Semaforos -------------------------------------------

to coordenadas-semaforos

   file-open "XCoor.txt"
   let coordinatesx []

   while [ not file-at-end? ] [
   set coordinatesx lput file-read coordinatesx
   ]
   file-close
   (foreach sort semaforos coordinatesx
    [ask ?1 [set xcor ?2]])

   file-open "YCoor.txt"
   let coordinatesy []

   while [ not file-at-end? ] [
    set coordinatesy lput file-read coordinatesy
  ]
  file-close
  (foreach sort semaforos coordinatesy
    [ask ?1 [set ycor ?2]])
end


to crear-semaforos
  create-semaforos 21[
    coordenadas-semaforos
    set size 1
    configurar-semaforos
    ]

end

to configurar-semaforos
ask semaforos [
  set sensor1? false
  coordenadas-semaforos
  if (xcor = 44) and (ycor >= 47 and ycor <= 53) [set sensor1? true set from 1 set color green]
  if (xcor = 107) and (ycor >= 47 and ycor <= 53) [set sensor1? true set from 2 set color red]
  if (xcor = 160) and (ycor >= 47 and ycor <= 53) [set sensor1? true set from 3 set color green]
  ]
end


;------------------------------ Comportamiento Autos -------------------------------

to random-zone-bus
  setxy (random 200)  47
  let target one-of other turtles-here
    if target != nobody [
      setxy (random 200)  47
      ]
end


to random-zone-cars

  let saberzona random 2
  let targe-lane saberzona

  ifelse (saberzona = 0) [

    set heading 90

    setxy (random 200) 47

    ]

  [if (saberzona = 1) [
      set heading 90
      setxy (random 200) 52

       ]
   ]

end

to comportamiento-autos
  configurar-velocidad
  mantener-distancia
  set change? false
  set max-patience ((random 50) + 10)
  set patience (max-patience - (random 10))

end

to configurar-velocidad

  set speed 0.1 + random-float 0.9
  set speed-limit 1
  set speed-min 0

end

to mantener-distancia
  if any? other turtles-here with [car? != false] [
    fd 1
    mantener-distancia
  ]
end
;-------------------- crear Observador ---------

to crear-manejador-tiempo
  create-inmoviles 1[
  set car? false
  set size 0.5
  set color black
  setxy  0  97
  ]
end
;--------------------- Creacion del Mundo y de los Agentes presentes (Autos , Semaforos)
to setup

  clear-all

  import-pcolors-rgb "Via.bmp"



  set-default-shape coches "car"
  set-default-shape buses "bus"
  set-default-shape camiones "truck"
  set-default-shape semaforos "circle"
  set cont_indv_desv 0
  set dias-lluviosos 0
  set dias-buenclima 0

  ;crear-semaforos
  crear-manejador-tiempo
  create-buses Num_Buses [
    set size 1
    set color turquoise - 1
    set heading 90
    set car? true
    set parar? false
    set numero-pasajeros random 80
    random-zone-bus
    comportamiento-autos
    ]

  create-coches Num_Coches [

    set size 1
    set color sky
    set car? true
    set parar? false
    random-zone-cars
    comportamiento-autos
     ]


  create-camiones Num_Camiones [
    set size 1
    set color lime - 1
    set car? true
    set parar? false
    random-zone-cars
    comportamiento-autos
     ]

  reset-ticks

end





; ------------------------Compotamiento en Ejecucion -------------------



to drive

 ask turtles with [car? = true]
   [
   move
   tomar-interseccion
   change-carril
   reproducir-buses
   reproducir-camiones

   ask turtles with [color = turquoise - 1][revisar-paraderos]
   ]

   ;ask semaforos [comportamiento-semaforos ]

   ask inmoviles[estado-climatico]
   revisar-zonas-muertas

 tick


end

to reproducir-buses
  if random-float 100 < porcen-aparicion-buses[
    hatch 1 [random-zone-bus comportamiento-autos]
    ]

end

to reproducir-camiones
  if random-float 100 < porcen-aparicion-camiones[
    hatch 1 [random-zone-cars comportamiento-autos]
    ]
end

;--------------------------------Procedimiento para Moverse y Elegir un nuevo Carril------------------------------------

to move

  ifelse (any? turtles-at 1 0) [


      set speed ([speed] of (one-of (turtles-at 1 0 ))) ; revisar que el target sea un carro y no un semaforo
      decelerate
    ]
    [
      ifelse (separacion = 2) [
        ifelse (any? turtles-at 2 0) [
          set speed ([speed] of (one-of turtles-at 2 0)) ;; revisar que el target sea un carro y no un semaforo
          decelerate
          set max-patience max-patience + 1
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

end

to change-carril

    ifelse (change? = false) [ signal ] [ change-lanes ]
    ;; Control for making sure no one crashes.
    ifelse (any? (turtles-at 1 0)) and (xcor != min-pxcor - .5) [
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

end

to accelerate
  set speed (speed + (aceleracion / 1000))
end


to decelerate
  set speed (speed - (desaceleracion / 1000))
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

to change-lanes  ;; turtle procedure
  ifelse (patience <= 0)
  [
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


  ifelse (target-lane = lane)
  [
    ifelse (target-lane = 0)
    [
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
      ifelse (pycor = 52) [
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
      ifelse (pycor = 47) [
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

;-----------------------Girar a la Derecha o a la Izuierda --------------------------------------------

to tomar-interseccion

ifelse ((xcor >= 68 and xcor <= 70) and ycor = 47)[


  cambiar-derecha


  ]
  [

    ifelse  ((xcor >= 88 and xcor <= 90) and ycor = 47) [
      cambiar-derecha


      ]

    [
      ifelse  ((xcor >= 110 and xcor <= 112) and ycor = 47)[
        cambiar-derecha

        ][
        ifelse ((xcor >= 47 and xcor <= 49) and ycor = 52) [
          cambiar-izquierda
          ][
          ifelse ((xcor >= 137 and xcor <= 139) and ycor = 52)[
            cambiar-izquierda
            ][]
          ]
        ]
      ]
    ]


end


to revisar-zonas-muertas

  ask turtles [
    if [pcolor] of patch-here = [160 32 0] [
      set car? false

    ]
  ]
end

to cambiar-izquierda
  let cambiar-izq (random 15)
  ifelse (cambiar-izq = 1)
  [
    set heading 0
    set cont_indv_desv cont_indv_desv + 1

  ]
  [
    set heading 90
  ]

end

to cambiar-derecha
  let cambiar-dere (random 15)
  ifelse (cambiar-dere = 1)
  [
    set heading 180
    set cont_indv_desv cont_indv_desv + 1

  ]
  [
    set heading 90
  ]
end



;-------------------------------Recoger o Dejar Pasajeros------------------------------------------

to revisar-paraderos

      ifelse (pcolor = [0 69 139]) [

      if (numero-pasajeros <= 80)
      [

          let decicion-dejar-recoger random 2
          ifelse (decicion-dejar-recoger = 1)
          [
            let num-random (random 15)
            set numero-pasajeros (numero-pasajeros - num-random)


            ifelse (xcor <= 107 )
            [
              set cont_indv_bogota_recogidos cont_indv_bogota_recogidos + num-random

            ]
            [
              if (xcor > 107)[
                set cont_indv_mosquera_recogidos cont_indv_mosquera_recogidos + num-random

                ]
            ]
          ]

          [
            let num-random (80 - numero-pasajeros)
            set numero-pasajeros (numero-pasajeros + num-random)


            ifelse (xcor <= 107 )[
              set cont_indv_bogota_dejados cont_indv_bogota_dejados + num-random

              ][
              if (xcor > 107)[
                set cont_indv_mosquera_dejados cont_indv_mosquera_dejados + num-random

                ]
              ]

          ]


      ]
      fd 1
      move
      ]

      [
        ]

end

;----------------------------------Semaforos ---------------------------------------------


to comportamiento-semaforos

  if (ticks mod 100 = 0)
  [
    foreach [1 3] [change-to-green]
    foreach [2] [change-to-red]
  ]

  if (ticks mod 60 = 0)
  [
    foreach [1 3] [change-to-red]
    foreach [2] [change-to-green]
    ]


end

to change-to-green
    set color green

end

to change-to-red
    set color red
end



;------------------------------- Soleado o  LLuvioso -----------------------------------------
to estado-climatico
ifelse (ticks mod 3000 = 0)[

   set estado-clima 0
   set dias-lluviosos dias-lluviosos + 1

  ][
  if (ticks mod 500 = 0)[
  set estado-clima 1
  set dias-buenclima dias-buenclima + 1]
  ]

end
@#$#@#$#@
GRAPHICS-WINDOW
205
20
1513
703
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
9
593
183
633
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
19
10
191
43
Num_Coches
Num_Coches
1
50
3
1
1
NIL
HORIZONTAL

SLIDER
15
299
187
332
aceleracion
aceleracion
0
50
10
1
1
NIL
HORIZONTAL

BUTTON
1531
105
1594
138
NIL
drive
T
1
T
OBSERVER
NIL
NIL
NIL
NIL
0

SWITCH
16
529
119
562
auto?
auto?
0
1
-1000

SLIDER
19
52
191
85
Num_Buses
Num_Buses
1
50
3
1
1
NIL
HORIZONTAL

SLIDER
19
94
191
127
Num_Camiones
Num_Camiones
1
50
3
1
1
NIL
HORIZONTAL

SLIDER
15
342
187
375
desaceleracion
desaceleracion
0
10
4
1
1
NIL
HORIZONTAL

SLIDER
16
446
188
479
duracion-luz-verde
duracion-luz-verde
0
50
0
1
1
NIL
HORIZONTAL

SLIDER
16
490
188
523
duracion-luz-amarilla
duracion-luz-amarilla
0
10
0
1
1
NIL
HORIZONTAL

BUTTON
1531
57
1637
90
drive-on-step
drive
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
0

PLOT
1670
26
2181
349
# Individuos
# Recogidos
tiempo
0.0
10.0
0.0
10.0
true
true
"" ""
PENS
"# Recogidos_Mosquera" 1.0 0 -13791810 true "" "plot cont_indv_mosquera_recogidos"
"# Recogidos_Bogota" 1.0 0 -2139308 true "" "plot cont_indv_bogota_recogidos"
"# Dejados_Mosquera" 1.0 0 -14070903 true "" "plot cont_indv_mosquera_dejados"
"# Dejados_Bogota" 1.0 0 -5298144 true "" "plot cont_indv_bogota_dejados"

SLIDER
15
382
187
415
separacion
separacion
0
2
1
1
1
NIL
HORIZONTAL

TEXTBOX
20
425
170
443
Semaforos
11
0.0
1

TEXTBOX
20
278
170
296
Comportamiento Autos
11
0.0
1

PLOT
1670
372
2050
572
Promedio de Velocidad
Tiempo
Velocidad
0.0
100.0
0.0
1.0
true
true
"" ""
PENS
"Promedio de Velocidad" 1.0 0 -13840069 true "" "plot mean [speed] of turtles with [car? = true]"

MONITOR
2077
374
2146
419
Estado Clima
estado-clima
17
1
11

PLOT
1671
580
2048
751
Rutas Desviadas
Tiempo
# Rutas desviadas
0.0
100.0
0.0
10.0
true
true
"" ""
PENS
"# Rutas Desviadas" 1.0 0 -14070903 true "" "plot cont_indv_desv"

PLOT
2072
442
2362
563
Clima
Tiempo
Dias LLuvios - Normal
0.0
10.0
0.0
10.0
true
true
"" ""
PENS
"# Dias LLuviosos" 1.0 0 -2674135 true "" "plot dias-lluviosos"
"# Dias Buen_Clima" 1.0 0 -13840069 true "" "plot dias-buenclima"

SLIDER
11
148
200
181
porcen-aparicion-coches
porcen-aparicion-coches
0
1
0.05
0.05
1
NIL
HORIZONTAL

SLIDER
16
193
200
226
porcen-aparicion-buses
porcen-aparicion-buses
0
1
0.1
0.05
1
NIL
HORIZONTAL

SLIDER
5
233
207
266
porcen-aparicion-camiones
porcen-aparicion-camiones
0
1
0.1
0.05
1
NIL
HORIZONTAL

PLOT
2067
578
2396
752
# De Vehiculos presentes en la Via
Tiempo
# De Vehiculos
0.0
10.0
0.0
10.0
true
true
"" ""
PENS
"Coches" 1.0 0 -13791810 true "" "plot count turtles with [color = sky]"
"Buses" 1.0 0 -15302303 true "" "plot count turtles with [color = turquoise - 1]"
"Camiones" 1.0 0 -14439633 true "" "plot count turtles with [color = lime - 1]"

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
