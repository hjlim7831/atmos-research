#!/bin/csh

gfortran -o combin ~/forf/combin_new.f

cat >! combin.com << ENDc
../results/blo_ulw.d
SEQ
../results/cinf_ulw.d
(22x,e15.7,////,20(40x,e16.7,/))
10
12
236 1
2
0
../regress/blo_sic-ulw_reg.d
SEQ
2
../regress/reg_sic-ulw.d
(///,20(7X,E13.5,/),/)
../results/cinf_sic.d
(22x,e15.7,////,20(41x,e15.7,/))
ENDc
./combin < combin.com

rm combin combin.com
