#!/bin/csh

gfortran -o recast ~/forf/recast.f

cat >! recast.com <<ENDc
../results/eof_sce.data
DIR
nofile
300            ; number of eof modes used
5400
1.0            ; scale factor
180 30
../results/blo_sce.d
SEQ
0              ; line skip amount
36             ; number of modes to be retained
../results/csf_sce.data
DIR
ENDc
./recast < recast.com

rm recast recast.com
