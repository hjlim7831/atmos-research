#!/bin/csh

f90 -o cseof ~/eigen/forf/cseof.f

cat >! cseof.com << END
0           ! 0: data file,  1: hcoef file,  2: covmat file
./pct_sst.d
(6e13.5)
20 1        ! size of array
473         ! total length of the time series
1           ! time index (=1) or space index (=2) first
12          ! period of nested fluctuations
6           ! # of spectral points
1           ! interval subdivisions for integrations
0           ! cycle period for detrending
473         ! size of covariance matrix (n x n)
99.0        ! percent variance
20          ! number of modes to be printed
1.          ! eof scale factor
2           ! 1: rc ts   2: cov
END
./cseof < cseof.com

mv inform.d ./cinf_sst.d
mv eigen.d  ./eig_sst.d
mv Bloch.d  ./blo_sst.d
mv pcts.d   ./cpct_sst.d
rm cseof cseof.com
