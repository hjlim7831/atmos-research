#!/bin/csh

gfortran -o cseof ~/forf/cseof.f

###
#  This program computes the cyclostationary eofs from a harmonizable
#  cyclostationary time series.
###

cat >! cseof.com << END
0           ! 0: data file,  1: hcoef file,  2: covmat file
../results/pct_shf.d
(6e13.5)
311 1       ! size of array
432         ! total length of the time series
1           ! time index (=1) or space index (=2) first
12          ! period of nested fluctuations
6           ! # of spectral points
1           ! interval subdivisions for integrations
0           ! cycle period for detrending
432         ! size of covariance matrix (n x n)
98.         ! percent variance
20          ! number of modes to be printed
1.          ! eof scale factor
2           ! 1: rc ts   2: cov
END

./cseof < cseof.com

mv inform.d ../results/cinf_shf.d
mv eigen.d  ../results/eig_shf.d
mv Bloch.d  ../results/blo_shf.d
mv pcts.d   ../results/cpct_shf.d
rm cseof cseof.com
