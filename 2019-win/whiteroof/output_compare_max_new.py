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

u1 = getvar(file1,"U10",timeidx=ALL_TIMES)[trunc:trunc+dlen,:,:]
u2 = getvar(file2,"U10",timeidx=ALL_TIMES)[trunc:trunc+dlen,:,:]
v1 = getvar(file1,"V10",timeidx=ALL_TIMES)[trunc:trunc+dlen,:,:]
v2 = getvar(file2,"V10",timeidx=ALL_TIMES)[trunc:trunc+dlen,:,:]

wspd1 = (u1**2.+v1**2.)**0.5
wspd2 = (u2**2.+v2**2.)**0.5

d1 = len(xlat[:,0])
d2 = len(xlat[0,:])
dt = len(T2[:,0,0])
print(d1)
print(d2)

mut1 = np.zeros(dt)
mut2 = np.zeros(dt)
muw1 = np.zeros(dt)
muw2 = np.zeros(dt)

n = 0
for i in range(d1):
	for j in range(d2):
		if lu[i,j] == 13 or lu[i,j]>=31:
			mut1 += T1[:,i,j]
			mut2 += T2[:,i,j]
			muw1 += wspd1[:,i,j]
			muw2 += wspd2[:,i,j]
			n += 1
mut1 = mut1/float(n)
mut2 = mut2/float(n)
muw1 = muw1/float(n)
muw2 = muw2/float(n)

uhi = mut2 - mut1

tday = int(dt/24)
maxut = np.full(tday,np.nan)
maxuhi = np.full(tday,np.nan)
maxw = np.full(tday,np.nan)

for i in range(tday):
	maxut[i] = (mut1[24*i+12]+mut1[24*i+13]+mut1[24*i+14])/3.
	maxuhi[i] = (uhi[24*i+12]+uhi[24*i+13]+uhi[24*i+14])/3.
	maxw[i] = muw1[24*i+12]

#maxut = np.delete(maxut,IND)
#maxuhi = np.delete(maxuhi,IND)
#maxw = np.delete(maxw,IND)



print(maxut)

xx = np.reshape(maxut,(-1,1))
#print(xx)

v1 = min(maxut)
v2 = max(maxut)
print(v1,v2)

model = LinearRegression()
model.fit(X=xx,y=maxuhi)
yyr = model.predict(xx)

mod = sm.OLS(maxuhi,maxut)
fii = mod.fit()
p_values = fii.summary2().tables[1]['P>|t|']
#print(p_values)
#print(fii.summary2().tables)
print(r2_score(maxuhi,yyr))



plt.figure(figsize=(6,6))
plt.scatter(maxut,maxuhi,c='k')
plt.plot(xx,yyr,'k')
plt.xlabel('2 m Temperature at 12:00 ($^\circ$C)')
plt.ylabel('White roof effect at 12:00 ($^\circ$C)')
plt.savefig('./scatter_del_15_T2_compare.png')
#plt.show()



