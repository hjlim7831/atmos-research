#!/usr/bin/env bash

#ns=1
#ne=6

export datah="/home/hjlim/2021-win/model"
export store_file="0124"

export wrf_runh="/home/hjlim/WRF-4.1.3/WRF/test"

for i in {1..9}
do
	mv $wrf_runh/em_real$i/wrfout* $datah/$store_file/alb0.$i/
done

#mv $wrf_runh/em_real9/wrfout* $datah/$store_file/alb0.9/

