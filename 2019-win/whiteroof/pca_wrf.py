import pandas as pd
import numpy as np
import matplotlib.pyplot as plt
import matplotlib.dates as dates
import sys
from metpy.calc import wind_direction
from netCDF4 import Dataset
from metpy.units import units
from wrf import getvar, ALL_TIMES
from sklearn.linear_model import LinearRegression
from sklearn.metrics import r2_score
import statsmodels.api as sm

diri1 = '~/2019-win/whiteroof/'
diri2 = 'csv/'
dim = 1
sday = 15
#dlen = 737
trunc = 3
dlen = 891-trunc

#sday = 21
#dlen = 24*7

sdt = (sday - 15)*24 # for ASOS data

fil1 = 'e2wrfout_d03_2018-07-14_12:00:00'
fil2 = 'e7wrfout_d03_2018-07-14_12:00:00'

ti1 = "alb 0.2"
ti2 = "alb 0.7"
idx = pd.date_range("2018-07-15 00:00:00",periods=dlen,freq='H')

IND = np.array([13,19,22,25,27,28,29,31,32,33,36])

file1 = Dataset(fil1)
file2 = Dataset(fil2)

xlat = getvar(file1,"lat")
xlon = getvar(file1,"lon")
lu = getvar(file1,"LU_INDEX")
T1 = getvar(file1,"T2",timeidx=ALL_TIMES)[trunc:trunc+dlen,:,:] -273.15
T2 = getvar(file2,"T2",timeidx=ALL_TIMES)[trunc:trunc+dlen,:,:] -273.15 #from 0:00 ~ 
#alb1 = getvar(file1,"ALBEDO",timeidx=ALL_TIMES)[trunc:trunc+dlen,:,:]
#alb2 = getvar(file2,"ALBEDO",timeidx=ALL_TIMES)[trunc:trunc+dlen,:,:]
#swd1 = getvar(file1,"SWDOWN",timeidx=ALL_TIMES)[trunc:trunc+dlen,:,:]
#swd2 = getvar(file2,"SWDOWN",timeidx=ALL_TIMES)[trunc:trunc+dlen,:,:]
#T1 = alb1*swd1
#T2 = alb2*swd2

DIM = units.meter/units.second
print(DIM)

u1 = getvar(file1,"U10",timeidx=ALL_TIMES)[trunc:trunc+dlen,:,:]
u2 = getvar(file2,"U10",timeidx=ALL_TIMES)[trunc:trunc+dlen,:,:]
v1 = getvar(file1,"V10",timeidx=ALL_TIMES)[trunc:trunc+dlen,:,:]
v2 = getvar(file2,"V10",timeidx=ALL_TIMES)[trunc:trunc+dlen,:,:]

wspd1 = (u1**2.+v1**2.)**0.5
wspd2 = (u2**2.+v2**2.)**0.5
wd1 = wind_direction(u1*DIM,v1*DIM)
wd2 = wind_direction(u2*DIM,v2*DIM)


d1 = len(xlat[:,0])
d2 = len(xlat[0,:])
dt = len(T2[:,0,0])
print(d1)
print(d2)

mut1 = np.zeros(dt)
mut2 = np.zeros(dt)
muu1 = np.zeros(dt)
muv1 = np.zeros(dt)
muu2 = np.zeros(dt)
muv2 = np.zeros(dt)

n = 0
for i in range(d1):
	for j in range(d2):
		if lu[i,j] == 13 or lu[i,j]>=31:
			mut1 += T1[:,i,j]
			mut2 += T2[:,i,j]
			muu1 += u1[:,i,j]
			muv1 += v1[:,i,j]
			muu2 += u2[:,i,j]
			muv2 += v2[:,i,j]
			n += 1
mut1 = mut1/float(n)
mut2 = mut2/float(n)
muu1 = muu1/float(n)
muv1 = muv1/float(n)
muu2 = muu2/float(n)
muv2 = muv2/float(n)

muwd1 = wind_direction(np.array(muu1)*DIM,np.array(muv1)*DIM)
muwd2 = wind_direction(np.array(muu2)*DIM,np.array(muv2)*DIM)

uhi = mut2 - mut1

tday = int(dt/24)
maxut = np.full(tday,np.nan)
maxuhi = np.full(tday,np.nan)
maxwd1 = np.full(tday,np.nan)
maxwd2 = np.full(tday,np.nan)

for i in range(tday):
	maxut[i] = mut1[24*i+15]
	maxuhi[i] = uhi[24*i+15]
	maxwd1[i] = muwd1[24*i+15]*180/np.pi
	maxwd2[i] = muwd2[24*i+15]*180/np.pi


#print(xx)

v1 = min(maxwd1)
v2 = max(maxwd1)
print(v1,v2)



sx = -0.5
ex = 360.5

plt.figure(figsize=(6,6))
plt.scatter(maxwd1,maxuhi,c='k')
plt.xlim(sx,ex)
plt.xticks(np.arange(0,361,step=90),[" ","E","S","W","N"])
plt.xlabel('10 m Wind Direction at 15:00 ($^\circ$C)')
plt.ylabel('White roof effect at 15:00 ($^\circ$C)')
plt.savefig('./scatter_del_wd_15_T2_compare.png')
plt.show()



