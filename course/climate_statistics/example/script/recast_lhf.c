#!/bin/csh

gfortran -o recast ~/forf/recast.f

cat >! recast.com <<ENDc
../results/eof_lhf.data
DIR
nofile
297            ; number of eof modes used
11520
1.0            ; scale factor
240 48
../results/blo_lhf.d
SEQ
0              ; line skip amount
36             ; number of modes to be retained
../results/csf_lhf.data
DIR
ENDc
./recast < recast.com

rm recast recast.com
