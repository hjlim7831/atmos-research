#!/bin/csh

f90 -o regress ~/util/regress_new_mean.f

cat >! regress.com << END
473 10      ; dimension (N x M) of the regression problem
./cpct_t2m.d
(6e13.5)
0          ; skip amount
1 473      ; data interval for target time series
./cpct_sst.d
(6e13.5)
0          ; skip amount
1 473      ; data interval for predictor time series
1 473      ; regression interval
regress.d
1          ; estimated output  (0: No,  1: Yes)
2          ; confidence interval  (0: no,  1: 80%,  2: 90%,  3: 95%,  4: 99%)
2          ; scaling option
./cinf_t2m.d
(41x,e15.7)
./cinf_sst.d
(41x,e15.7)
END
./regress < regress.com
mv regress.d regress.s

cat >! regress.com << END
473 10      ; dimension (N x M) of the regression problem
./cpct_t2m.d
(6e13.5)
73         ; skip amount
1 473      ; data interval for target time series
./cpct_sst.d
(6e13.5)
0          ; skip amount
1 473      ; data interval for predictor time series
1 473      ; regression interval
regress.d
1          ; estimated output  (0: No,  1: Yes)
2          ; confidence interval  (0: no,  1: 80%,  2: 90%,  3: 95%,  4: 99%)
2          ; scaling option
./cinf_t2m.d
(/,41x,e15.7)
./cinf_sst.d
(41x,e15.7)
END
./regress < regress.com
cat regress.d >> regress.s

cat >! regress.com << END
473 10      ; dimension (N x M) of the regression problem
./cpct_t2m.d
(6e13.5)
146        ; skip amount
1 473      ; data interval for target time series
./cpct_sst.d
(6e13.5)
0          ; skip amount
1 473      ; data interval for predictor time series
1 473      ; regression interval
regress.d
1          ; estimated output  (0: No,  1: Yes)
2          ; confidence interval  (0: no,  1: 80%,  2: 90%,  3: 95%,  4: 99%)
2          ; scaling option
./cinf_t2m.d
(//,41x,e15.7)
./cinf_sst.d
(41x,e15.7)
END
./regress < regress.com
cat regress.d >> regress.s

cat >! regress.com << END
473 10      ; dimension (N x M) of the regression problem
./cpct_t2m.d
(6e13.5)
219        ; skip amount
1 473      ; data interval for target time series
./cpct_sst.d
(6e13.5)
0          ; skip amount
1 473      ; data interval for predictor time series
1 473      ; regression interval
regress.d
1          ; estimated output  (0: No,  1: Yes)
2          ; confidence interval  (0: no,  1: 80%,  2: 90%,  3: 95%,  4: 99%)
2          ; scaling option
./cinf_t2m.d
(///,41x,e15.7)
./cinf_sst.d
(41x,e15.7)
END
./regress < regress.com
cat regress.d >> regress.s

cat >! regress.com << END
473 10      ; dimension (N x M) of the regression problem
./cpct_t2m.d
(6e13.5)
292        ; skip amount
1 473      ; data interval for target time series
./cpct_sst.d
(6e13.5)
0          ; skip amount
1 473      ; data interval for predictor time series
1 473      ; regression interval
regress.d
1          ; estimated output  (0: No,  1: Yes)
2          ; confidence interval  (0: no,  1: 80%,  2: 90%,  3: 95%,  4: 99%)
2          ; scaling option
./cinf_t2m.d
(4(/),41x,e15.7)
./cinf_sst.d
(41x,e15.7)
END
./regress < regress.com
cat regress.d >> regress.s
mv regress.s ./reg_sst-t2m.d

rm regress regress.com regress.d
rm Y_err.d Y_est.d
