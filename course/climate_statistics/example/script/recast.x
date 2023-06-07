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
../regress/blo_airT_reg.d
SEQ
0              ; line skip amount
480            ; number of modes to be retained
../regress/csf_airT_reg.data
DIR
ENDc
./recast < recast.com

rm recast recast.com
