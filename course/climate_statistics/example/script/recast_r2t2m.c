#!/bin/csh

gfortran -o recast ~/forf/recast.f

cat >! recast.com <<ENDc
../results/eof_r2t2m.data
DIR
nofile
23             ; number of eof modes used
11520
1.0            ; scale factor
240 48
../results/blo_r2t2m.d
SEQ
0              ; line skip amount
24             ; number of modes to be retained
../results/csf_r2t2m.data
DIR
ENDc
./recast < recast.com

rm recast recast.com
