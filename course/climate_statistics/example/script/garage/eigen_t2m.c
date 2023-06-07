#!/bin/csh

gfortran -o eigen ~/forf/eigenx.f

cat >! eof.com <<ENDc
../data/t2m.data
DIR
240 121        ; dimension of sampling stations
432            ; number of sampling points at each station
2              ; read   1=time index first   2=space index first
0              ; moving average lag (0:No smoothing)
1              ; cycle period for removing mean  (0: No)
0              ; area adjustment  (0: No,  1: Yes)
0.  5.         ; starting latitude and increment for area adjustment
99.            ; percent variance
1.             ; EOF scaling factor
40             ; number of EOFs to be printed
0              ; PC normalization  (0: No,  1: Yes)
../results/eof_t2m.data
DIR
../results/pct_t2m.d
(6e13.5)
ENDc
./eigen < eof.com

mv inform.d ../results/inf_t2m.d
mv avg.d    ../results/avg_t2m.d
rm eigen eof.com