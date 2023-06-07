#!/bin/csh

f90 -o cseof_h ~/eigen/forf/cseof_h.f

###
#  This program computes the cyclostationary eofs from a harmonizable
#  cyclostationary time series.
###

cat >! cseof.com << END
../data/airT_ws.data
DIR
99.0        ! explain 99% of variability
3480        ! (=120 days x 29 years) total length of the time series
120         ! period of nested fluctuations
60          ! # of spectral points
1           ! interval subdivisions for integrations
20          ! number of modes to be printed
120         ! length of the output
1           ! resolution of the output
1           ! cycle period for detrending
0           ! window type
0           ! lag
6           ! 1: rc ts   2: Bloch fts   4: pc ts   8: cov   16: egv   32: egf
END

./cseof_h < cseof.com

mv inform.d ../results/cinf_airT_ws.d
mv eigen.d  ../results/eig_airT_ws.d
mv bloch.d  ../results/blo_airT_ws.d
mv pc_ts.d  ../results/cpct_airT_ws.d
mv fort.17  ../results/avg_airT_ws.d
rm cseof_h cseof.com hcoef.d
