#!/bin/csh

f90 -o combin ~/util/combin_new.f

cat >! combin.com << ENDc
./blo_sst.d
SEQ
./cinf_sst.d
(22x,e15.7,////,20(40x,e16.7,/))
10         ; number of predictor PC time series
12         ; nested period
20 1       ; eof stations
5
0
./blo_sst_reg.d
SEQ
2
./reg_sst-t2m.d
(///,10(7X,E13.5,/),/)
./cinf_t2m.d
(22x,e15.7,////,10(41x,e15.7,/))
ENDc
./combin < combin.com

rm combin combin.com
