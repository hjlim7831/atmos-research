#!/bin/csh

gfortran -o regress ~/forf/regress_new_mean.f

cat >! regress.com << END
432  10     ; dimension (N x M) of the regression problem
../results/cpct_sce.d
(6e13.5)
0          ; skip amount
1 432      ; data interval for target time series
../results/cpct_prcp.d
(6e13.5)
0          ; skip amount
1 432      ; data interval for predictor time series
1 432      ; regression interval
regress.d
1          ; estimated output  (0: No,  1: Yes)
2          ; confidence interval  (0: no,  1: 80%,  2: 90%,  3: 95%,  4: 99%)
2          ; scaling option
../results/cinf_sce.d
(41x,e15.7)
../results/cinf_prcp.d
(41x,e15.7)
END
./regress < regress.com
\mv regress.d regress.s

cat >! regress.com << END
432 10     ; dimension (N x M) of the regression problem
../results/cpct_sce.d
(6e13.5)
432        ; skip amount
1 432      ; data interval for target time series
../results/cpct_prcp.d
(6e13.5)
0          ; skip amount
1 432      ; data interval for predictor time series
1 432      ; regression interval
regress.d
1          ; estimated output  (0: No,  1: Yes)
2          ; confidence interval  (0: no,  1: 80%,  2: 90%,  3: 95%,  4: 99%)
2          ; scaling option
../results/cinf_sce.d
(/,41x,e15.7)
../results/cinf_prcp.d
(41x,e15.7)
END
./regress < regress.com
cat regress.d >> regress.s
\mv regress.s ../regress/reg_sce-prcp.d

\rm regress regress.com regress.d
\rm - Y_err.d Y_est.d

gfortran -o combin ~/forf/combin_new.f

cat >! combin.com << ENDc
../results/blo_prcp.d
SEQ
../results/cinf_prcp.d
(22x,e15.7,////,20(40x,e16.7,/))
10
12
300 1
2
0
../regress/blo_sce-prcp_reg.d
SEQ
2
../regress/reg_sce-prcp.d
(///,20(7X,E13.5,/),/)
../results/cinf_sce.d
(22x,e15.7,////,20(41x,e15.7,/))
ENDc
./combin < combin.com

\rm combin combin.com

gfortran -o recast ~/forf/recast.f

cat >! recast.com <<ENDc
../results/eof_prcp.data
DIR
nofile
300            ; number of eof modes used
11520
1.0            ; scale factor
240 48
../regress/blo_sce-prcp_reg.d
SEQ
0              ; line skip amount
24             ; number of modes to be retained
../results/csf_sce-prcp_reg.data
DIR
ENDc
./recast < recast.com

\rm recast recast.com


