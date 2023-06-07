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


file1 = Dataset(fil1)
file2 = Dataset(fil2)

xlat = getvar(file1,"lat")
xlon = getvar(file1,"lon")
lu = getvar(file1,"LU_INDEX")
T1 = getvar(file1,"T2",timeidx=ALL_TIMES)[trunc:trunc+dlen,:,:] -273.15
T2 = getvar(file2,"T2",timeidx=ALL_TIMES)[trunc:trunc+dlen,:,:] -273.15 #from 0:00 ~ 
#alb1 = getvar(file1,"ALBEDO",timeidx=ALL_TIMES)[trunc:trunc+dlen,:,:]
#alb2 = getvar(file2,"ALBEDO",timeidx=ALL_TIMES)[trunc:trunc+dlen,:,:]
swd1 = getvar(file1,"SWDOWN",timeidx=ALL_TIMES)[trunc:trunc+dlen,:,:]
swd2 = getvar(file2,"SWDOWN",timeidx=ALL_TIMES)[trunc:trunc+dlen,:,:]
rnc1 = getvar(file1,"RAINC",timeidx=ALL_TIMES)[trunc:trunc+dlen,:,:]
rnc2 = getvar(file2,"RAINC",timeidx=ALL_TIMES)[trunc:trunc+dlen,:,:]
rnnc1 = getvar(file1,"RAINNC",timeidx=ALL_TIMES)[trunc:trunc+dlen,:,:]
rnnc2 = getvar(file2,"RAINNC",timeidx=ALL_TIMES)[trunc:trunc+dlen,:,:]

apr1 = rnc1 + rnnc1
apr2 = rnc2 + rnnc2

n1 = len(rnnc1[0,:,0])
n2 = len(rnnc1[0,0,:])

pr1 = np.zeros((dlen,n1,n2))
pr2 = np.zeros((dlen,n1,n2))

for i in range(dlen-1):
	pr1[i+1,:,:] = apr1[i+1,:,:] - apr1[i,:,:]
	pr2[i+1,:,:] = apr2[i+1,:,:] - apr2[i,:,:]


#print(pr1)
#print(pr2)

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
mpr1 = np.zeros(dt)
mpr2 = np.zeros(dt)
mu1 = np.zeros(dt)
mu2 = np.zeros(dt)
mv1 = np.zeros(dt)
mv2 = np.zeros(dt)

n = 0
for i in range(d1):
	for j in range(d2):
		if lu[i,j] == 13 or lu[i,j]>=31:
			mut1 += T1[:,i,j]
			mut2 += T2[:,i,j]
			muw1 += wspd1[:,i,j]
			muw2 += wspd2[:,i,j]
			mpr1 += pr1[:,i,j]
			mpr2 += pr2[:,i,j]
			mu1 += u1[:,i,j]
			mu2 += u2[:,i,j]
			mv1 += v1[:,i,j]
			mv2 += v2[:,i,j]
			n += 1

mut1 = mut1/float(n)
mut2 = mut2/float(n)
muw1 = muw1/float(n)
muw2 = muw2/float(n)
mpr1 = mpr1/float(n)
mpr2 = mpr2/float(n)
mu1 = mu1/float(n)
mu2 = mu2/float(n)
mv1 = mv1/float(n)
mv2 = mv2/float(n)

uhi = mut1 - mut2

tday = int(dt/24)
maxut = np.full(tday,np.nan)
maxuhi = np.full(tday,np.nan)
maxuhi2 = np.full(tday,np.nan)
maxuhi3 = np.full(tday,np.nan)
maxw = np.full(tday,np.nan)
meanw1 = np.full(tday,np.nan)
meanw2 = np.full(tday,np.nan)
w115 = np.full(tday,np.nan)
w215 = np.full(tday,np.nan)
meanu1 = np.full(tday,np.nan)
meanu2 = np.full(tday,np.nan)
meanv1 = np.full(tday,np.nan)
meanv2 = np.full(tday,np.nan)
u115 = np.full(tday,np.nan)
u215 = np.full(tday,np.nan)
v115 = np.full(tday,np.nan)
v215 = np.full(tday,np.nan)


meanpr1 = np.full(tday,np.nan)
meanpr2 = np.full(tday,np.nan)

for i in range(tday):
	maxut[i] = max(mut1[24*i:24*(i+1)])
	maxuhi2[i] = max(uhi[24*i:24*(i+1)])
	maxuhi3[i] = max(mut1[24*i:24*(i+1)]) - max(mut2[24*i:24*(i+1)])

	for j in range(24):
		if mut1[24*i+j] == maxut[i]:
			maxuhi[i] = uhi[24*i+j]
	meanw1[i] = np.mean(muw1[24*i:24*(i+1)])
	meanw2[i] = np.mean(muw2[24*i:24*(i+1)])
	meanu1[i] = np.mean(mu1[24*i:24*(i+1)])
	meanu2[i] = np.mean(mu2[24*i:24*(i+1)])
	meanv1[i] = np.mean(mv1[24*i:24*(i+1)])
	meanv2[i] = np.mean(mv2[24*i:24*(i+1)])

	w115[i] = muw1[24*i+14]
	w215[i] = muw2[24*i+14]
	u115[i] = mu1[24*i+14]
	u215[i] = mu2[24*i+14]
	v115[i] = mv1[24*i+14]
	v215[i] = mv2[24*i+14]

	meanpr1[i] = np.nansum(mpr1[24*i:24*(i+1)])
	meanpr2[i] = np.nansum(mpr2[24*i:24*(i+1)])

# wdano1

wdano1 = ((meanu1-u115)**2.+(meanv1-v115)**2.)**0.5
wdano2 = ((meanu2-u215)**2.+(meanv2-v215)**2.)**0.5


#print(maxut)
#print(maxuhi2)
#print(maxuhi3)
#print(meanw)
#print(meanpr1)
#print(meanpr2)
#print(meanw1)
#print(meanw2)
#print(w115)
#print(w215)
print(wdano1)
print(wdano2)


xx = np.reshape(maxut,(-1,1))
#print(xx)

v1 = min(maxut)
v2 = max(maxut)
#print(v1,v2)

model = LinearRegression()
model.fit(X=xx,y=maxuhi2)
yyr = model.predict(xx)

mod = sm.OLS(maxuhi,maxut)
fii = mod.fit()
p_values = fii.summary2().tables[1]['P>|t|']
#print(p_values)
#print(fii.summary2().tables)
#print(r2_score(maxuhi2,yyr))



plt.figure(figsize=(6,6))
plt.scatter(maxut,maxuhi2,c='k')
plt.plot(xx,yyr,'k')
plt.xlabel('daily maximum 2-m temperature ($^\circ$C)')
plt.ylabel('daily maximum white roof effect ($^\circ$C)')
plt.savefig('./New_scatter_max_T2_compare.png')
#plt.show()



