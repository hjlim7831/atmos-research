from __future__ import print_function
from wrf import getvar, ALL_TIMES
import pandas as pd
import numpy as np
import matplotlib.pyplot as plt
from netCDF4 import Dataset

filo1 = "V1wrfout_d03_2018-07-14_12:00:00"
filo2 = "V4wrfout_d03_2018-07-14_12:00:00"
filo3 = "e0wrfout_d03_2018-07-14_12:00:00"
filo4 = "e1wrfout_d03_2018-07-14_12:00:00"
filo5 = "e4wrfout_d03_2018-07-14_12:00:00"

dlen = 21

ncfile1 = Dataset(filo1)
ncfile2 = Dataset(filo2)
ncfile3 = Dataset(filo3)
ncfile4 = Dataset(filo4)
ncfile5 = Dataset(filo5)


t1 = getvar(ncfile1,"T2",timeidx=ALL_TIMES)
t2 = getvar(ncfile2,"T2",timeidx=ALL_TIMES)
t3 = getvar(ncfile3,"T2",timeidx=ALL_TIMES)
t4 = getvar(ncfile4,"T2",timeidx=ALL_TIMES)
t5 = getvar(ncfile5,"T2",timeidx=ALL_TIMES)

lu = getvar(ncfile1,"LU_INDEX",timeidx=ALL_TIMES)
dim1 = len(lu)
dim2 = len(lu[0])
dim3 = len(lu[0][0])
print(dim1)
print(dim2)
print(dim3)

urbt = np.zeros((5,dim1))

n0 = 0.
for i2 in range(dim2):
	for i3 in range(dim3):
		if lu[0,i2,i3] == 13. or lu[0,i2,i3] >=30.:
			urbt[0] += t1[:,i2,i3]
			urbt[1] += t2[:,i2,i3]
			urbt[2] += t3[:,i2,i3]
			urbt[3] += t4[:,i2,i3]
			urbt[4] += t5[:,i2,i3]
			n0 += 1.

urbt = urbt/n0


plt.figure(figsize=(6,6))
plt.plot([i for i in range(dim1)],urbt[0],label="V3_UCM")
plt.plot([i for i in range(dim1)],urbt[1],label="V3_SNUUCM")
plt.plot([i for i in range(dim1)],urbt[2],label="V4_NOUCM")
plt.plot([i for i in range(dim1)],urbt[3],label="V4_UCM")
plt.plot([i for i in range(dim1)],urbt[4],label="V4_SNUUCM")
plt.xlabel('time (hr)')
plt.ylabel('2 m air temperature (K)')
plt.legend()
plt.show()









