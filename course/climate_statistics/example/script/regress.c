#!/bin/csh

f90 -o regress ~/util/regress_new_mean.f

cat >! regress.com << END
3480 20     ; dimension (N x M) of the regression problem
../results/cpct_airT_ws.d
(6e13.5)
0          ; skip amount
1 3480     ; data interval for target time series
../results/cpct_airT.d
(6e13.5)
0          ; skip amount
1 3480     ; data interval for predictor time series
1 3480     ; regression interval
regress.d
1          ; estimated output  (0: No,  1: Yes)
2          ; confidence interval  (0: no,  1: 80%,  2: 90%,  3: 95%,  4: 99%)
2          ; scaling option
../results/cinf_airT_ws.d
(41x,e15.7)
../results/cinf_airT.d
(41x,e15.7)
END
./regress < regress.com
mv regress.d regress.s

cat >! regress.com << END
3480 20     ; dimension (N x M) of the regression problem
../results/cpct_airT_ws.d
(6e13.5)
580        ; skip amount
1 3480     ; data interval for target time series
../results/cpct_airT.d
(6e13.5)
0          ; skip amount
1 3480     ; data interval for predictor time series
1 3480     ; regression interval
regress.d
1          ; estimated output  (0: No,  1: Yes)
2          ; confidence interval  (0: no,  1: 80%,  2: 90%,  3: 95%,  4: 99%)
2          ; scaling option
../results/cinf_airT_ws.d
(/,41x,e15.7)
../results/cinf_airT.d
(41x,e15.7)
END
./regress < regress.com
cat regress.d >> regress.s

cat >! regress.com << END
3480 20     ; dimension (N x M) of the regression problem
../results/cpct_airT_ws.d
(6e13.5)
1160       ; skip amount
1 3480     ; data interval for target time series
../results/cpct_airT.d
(6e13.5)
0          ; skip amount
1 3480     ; data interval for predictor time series
1 3480     ; regression interval
regress.d
1          ; estimated output  (0: No,  1: Yes)
2          ; confidence interval  (0: no,  1: 80%,  2: 90%,  3: 95%,  4: 99%)
2          ; scaling option
../results/cinf_airT_ws.d
(//,41x,e15.7)
../results/cinf_airT.d
(41x,e15.7)
END
./regress < regress.com
cat regress.d >> regress.s

cat >! regress.com << END
3480 20     ; dimension (N x M) of the regression problem
../results/cpct_airT_ws.d
(6e13.5)
1740       ; skip amount
1 3480     ; data interval for target time series
../results/cpct_airT.d
(6e13.5)
0          ; skip amount
1 3480     ; data interval for predictor time series
1 3480     ; regression interval
regress.d
1          ; estimated output  (0: No,  1: Yes)
2          ; confidence interval  (0: no,  1: 80%,  2: 90%,  3: 95%,  4: 99%)
2          ; scaling option
../results/cinf_airT_ws.d
(///,41x,e15.7)
../results/cinf_airT.d
(41x,e15.7)
END
./regress < regress.com
cat regress.d >> regress.s
mv regress.s ../regress/reg_airT-airT_ws.d

rm regress regress.com regress.d
rm Y_err.d Y_est.d
