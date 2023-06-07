#!/bin/csh

f90 -o shuffle ~/util/shuffle.f

cat >! shuffle.com <<ENDc
4
../data/air8.data
../data/hgt8.data
../data/uwnd8.data
../data/vwnd8.data
DIR
23 21          ; array size
3480           ; time step
1. 1. 1. 1.    ; scale factor for individual arrays
../data/level8.data
DIR
ENDc
./shuffle < shuffle.com

rm shuffle shuffle.com
