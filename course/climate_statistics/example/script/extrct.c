#!/bin/csh

f90 -o extrct ~/util/extrct.f

cat >! extrct.com <<ENDc
../data/air.data
../data/air_win.data
DIR
1948           ; starting year
1979 2009      ; extraction range
144 73         ; array size
40 62 46 66    ; extraction x-y range
335 365        ; extraction day range
1              ; averaging interval
0              ; moving average lag
1.0            ; scale factor
DIR
ENDc
./extrct < extrct.com

rm extrct extrct.com
