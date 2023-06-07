#!/bin/csh

f90 -o eigen ~/forf/eigen.f

cat >! eof.com <<ENDc
../data/air_kor.data
DIR
23 21          ; dimension of sampling stations
3480           ; number of sampling points at each station
2              ; read   1=time index first   2=space index first
0              ; moving average lag (0:No smoothing)
1              ; cycle period for removing mean  (0: No)
0              ; area adjustment  (0: No,  1: Yes)
0.  5.         ; starting latitude and increment for area adjustment
99.            ; percent variance
1.             ; EOF scaling factor
30             ; number of EOFs to be printed
0              ; PC normalization  (0: No,  1: Yes)
../results/eof_airT.data
DIR
../results/pct_airT.d
(6e13.5)
ENDc
./eigen < eof.com

mv inform.d ../results/inf_airT.d
mv avg.d    ../results/avg_airT.d
rm eigen eof.com
