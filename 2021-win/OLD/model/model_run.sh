#!/usr/bin/env bash

export datah="/home/hjlim/2021-win/model"
export run_file="0124"

export wrf_runh="/home/hjlim/WRF-4.1.3/WRF/test"

#for i in {1..9}
for i in {1..8}
do
	cp $datah/$run_file/wrf_input/* $wrf_runh/em_real$i/
#	qsub $wrf_runh/em_real$i/wrf.pbs
done

for i in {1..8}
do
	cd $wrf_runh/em_real$i/
	qsub wrf.pbs
done


