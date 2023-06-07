#!/bin/csh

gfortran -o regress ~/forf/regress_new_mean.f

cat >! regress.com << END
432  10     ; dimension (N x M) of the regression problem
../results/cpct_sic.d
(6e13.5)
0          ; skip amount
1 432      ; data interval for target time series
../results/cpct_ulw.d
(6e13.5)
0          ; skip amount
1 432      ; data interval for predictor time series
1 432      ; regression interval
regress.d
1          ; estimated output  (0: No,  1: Yes)
2          ; confidence interval  (0: no,  1: 80%,  2: 90%,  3: 95%,  4: 99%)
2          ; scaling option
../results/cinf_sic.d
(41x,e15.7)
../results/cinf_ulw.d
(41x,e15.7)
END
./regress < regress.com
mv regress.d regress.s

cat >! regress.com << END
432 10     ; dimension (N x M) of the regression problem
../results/cpct_sic.d
(6e13.5)
432        ; skip amount
1 432      ; data interval for target time series
../results/cpct_ulw.d
(6e13.5)
0          ; skip amount
1 432      ; data interval for predictor time series
1 432      ; regression interval
regress.d
1          ; estimated output  (0: No,  1: Yes)
2          ; confidence interval  (0: no,  1: 80%,  2: 90%,  3: 95%,  4: 99%)
2          ; scaling option
../results/cinf_sic.d
(/,41x,e15.7)
../results/cinf_ulw.d
(41x,e15.7)
END
./regress < regress.com
cat regress.d >> regress.s
mv regress.s ../regress/reg_sic-ulw.d

rm regress regress.com regress.d
r - Y_err.d Y_est.d
