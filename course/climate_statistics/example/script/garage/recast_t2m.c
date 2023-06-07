#!/bin/csh

gfortran -o recast ~/forf/recast.f

cat >! recast.com <<ENDc
../results/eof_t2m.data
DIR
nofile
27             ; number of eof modes used
29040
1.0            ; scale factor
240 121
../results/blo_t2m.d
SEQ
0              ; line skip amount
24             ; number of modes to be retained
../results/csf_t2m.data
DIR
ENDc
./recast < recast.com

rm recast recast.com
