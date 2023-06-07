#!/bin/csh

f90 -o proces ~/util/proces.f

cat >! proces.com <<ENDc
../data/ersst.data
DIR
../data/pac_sst.data
DIR
180 89         ; input array size
0 358.         ; longitude range
-88. 88.       ; latitude range
1947           ; number of time steps
1              ; total number of variables
1              ; the sequence number of variables to be extracted
-9.99e+08      ; special value to skip
1.0            ; scale factor
120. 280. 2.   ; longitude extraction range and interval
-30. 30. 2.    ; latitude extraction range and interval
ENDc
./proces < proces.com

mv indx.d indx_pac.d
rm proces proces.com
