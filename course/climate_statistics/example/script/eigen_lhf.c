#!/bin/csh

gfortran -o eigen ~/forf/eigenx.f

cat >! eof.com <<ENDc
../data/lhf.data
DIR
240 48         ; dimension of sampling stations
432            ; number of sampling points at each station
2              ; read   1=time index first   2=space index first
0              ; moving average lag (0:No smoothing)
12             ; cycle period for removing mean  (0: No)
0              ; area adjustment  (0: No,  1: Yes)
0.  5.         ; starting latitude and increment for area adjustment
98.            ; percent variance
1.             ; EOF scaling factor
300            ; number of EOFs to be printed
0              ; PC normalization  (0: No,  1: Yes)
../results/eof_lhf.data
DIR
../results/pct_lhf.d
(6e13.5)
ENDc
./eigen < eof.com

\mv inform.d ../results/inf_lhf.d
\mv avg.d    ../results/avg_lhf.d
\rm eigen eof.com
