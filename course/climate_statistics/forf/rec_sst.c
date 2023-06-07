#!/bin/csh

f90 -o recast ~/util/recast.f

cat >! recast.com <<ENDc
./eof_sst.data
DIR
nofile
20             ; number of eof modes used
9120
1.0            ; scale factor
240 38
./blo_sst.d
SEQ
0              ; line skip amount
120            ; number of modes to be retained
./csf_sst.data
DIR
ENDc
./recast < recast.com

rm recast recast.com
