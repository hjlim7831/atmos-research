#!/bin/csh

f90 -o recast ~/util/recast.f

cat >! recast.com <<ENDc
../results/eof_airT.data
DIR
nofile
10             ; number of eof modes used
483
1.0            ; scale factor
23 21
../results/blo_airT.d
SEQ
0              ; line skip amount
1200           ; number of modes to be retained
../results/csf_airT.data
DIR
ENDc
./recast < recast.com

rm recast recast.com
