#!/bin/csh

f90 -o eigen ~/eigen/forf/eigenx.f

cat >! eof.com <<ENDc
./sst.data
DIR
240 38         ; dimension of sampling stations
473            ; number of sampling points at each station
2              ; read   1=time index first   2=space index first
0              ; moving average lag (0:No smoothing)
1              ; cycle period for removing mean  (0: No)
0              ; area adjustment  (0: No,  1: Yes)
0. 5.          ; starting latitude and increment for area adjustment
99.99          ; percent variance
1.             ; EOF scaling factor
100            ; number of EOFs to be printed
0              ; PC normalization  (0: No,  1: Yes)
./eof_sst.data
DIR
./pct_sst.d
(6e13.5)
ENDc
./eigen < eof.com

mv inform.d ./inf_sst.d
mv avg.d    ./avg_sst.d
rm eigen eof.com
