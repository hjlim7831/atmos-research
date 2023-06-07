#!/bin/csh

f90 -o combin ~/util/combin_new.f

cat >! combin.com << ENDc
../results/blo_airT.d
SEQ
../results/cinf_airT.d
(22x,e15.7,////,20(40x,e16.7,/))
20
120
10 1
4
0
../regress/blo_airT_reg.d
SEQ
2
../regress/reg_airT-airT_ws.d
(///,20(7X,E13.5,/),/)
../results/cinf_airT_ws.d
(22x,e15.7,////,10(41x,e15.7,/))
ENDc
./combin < combin.com

rm combin combin.com
