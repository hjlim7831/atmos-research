#!/bin/csh

gfortran -o recast ~/forf/recast.f

cat >! recast.com <<ENDc
../results/eof_sic.data
DIR
nofile
195            ; number of eof modes used
11520
1.0            ; scale factor
240 48
../results/blo_sic.d
SEQ
0              ; line skip amount
24             ; number of modes to be retained
../results/csf_sic.data
DIR
ENDc
./recast < recast.com

\rm recast recast.com
