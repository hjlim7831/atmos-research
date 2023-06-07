#!/bin/csh

gfortran -o recast ~/forf/recast.f

cat >! recast.com <<ENDc
../results/eof_dlw.data
DIR
nofile
278            ; number of eof modes used
11520
1.0            ; scale factor
240 48
../results/blo_dlw.d
SEQ
0              ; line skip amount
36             ; number of modes to be retained
../results/csf_dlw.data
DIR
ENDc
./recast < recast.com

rm recast recast.com
