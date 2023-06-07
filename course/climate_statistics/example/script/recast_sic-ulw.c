#!/bin/csh

gfortran -o recast ~/forf/recast.f

cat >! recast.com <<ENDc
../results/eof_ulw.data
DIR
nofile
236            ; number of eof modes used
11520
1.0            ; scale factor
240 48
../regress/blo_sic-ulw_reg.d
SEQ
0              ; line skip amount
24             ; number of modes to be retained
../results/csf_sic-ulw_reg.data
DIR
ENDc
./recast < recast.com

rm recast recast.com
