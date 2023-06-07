#!/bin/csh

f90 -o cseof ~/forf/cseof.f

###
#  This program computes the cyclostationary eofs from a harmonizable
#  cyclostationary time series.
###

cat >! cseof.com << END
0           ! 0: data file,  1: hcoef file,  2: covmat file
../results/pct_airT.d
(6e13.5)
10 1        ! size of array
3480        ! total length of the time series
1           ! time index (=1) or space index (=2) first
120         ! period of nested fluctuations
60          ! # of spectral points
1           ! interval subdivisions for integrations
0           ! cycle period for detrending
3480        ! size of covariance matrix (n x n)
99.         ! percent variance
20          ! number of modes to be printed
1.          ! eof scale factor
2           ! 1: rc ts   2: cov
END

./cseof < cseof.com

mv inform.d ../results/cinf_airT.d
mv eigen.d  ../results/eig_airT.d
mv Bloch.d  ../results/blo_airT.d
mv pcts.d   ../results/cpct_airT.d
rm cseof cseof.com
