#!/bin/csh

gfortran -o recast ~/forf/recast.f

cat >! recast.com <<ENDc
../results/eof_rt2m.data
DIR
nofile
160            ; number of eof modes used
11520
1.0            ; scale factor
240 48
../results/blo_rt2m.d
SEQ
0              ; line skip amount
24             ; number of modes to be retained
../results/csf_rt2m.data
DIR
ENDc
./recast < recast.com

rm recast recast.com
