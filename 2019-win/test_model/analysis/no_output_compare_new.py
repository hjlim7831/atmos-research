import pandas as pd
import numpy as np
import matplotlib.pyplot as plt
import matplotlib.dates as dates
import sys
import csv
from wrf import getvar, ALL_TIMES
from metpy.calc import wind_direction
from netCDF4 import Dataset
from metpy.units import units


diri1 = '~/2019-win/test_model/'
diri2 = 'csv/'
dim = 1
sday = 15
#dlen = 737
trunc = 3
dlen = 891-trunc

#sday = 21
#dlen = 24*7

sdt = (sday - 15)*24 # for ASOS data

#csvname = 'wt2.csv'

#fil1 = 'z3_a2wrf'
#fil2 = 'z3_a7wrf'

csvname = 'wt.csv'

fil1 = 'z3_a2wrf'
fil2 = 'z3_a7wrf'

ti1 = "alb 0.2"
ti2 = "alb 0.7"
idx = pd.date_range("2018-07-15 00:00:00",periods=dlen,freq='H')

IND = np.array([13,22,29,31,36])


file1 = Dataset(fil1)
file2 = Dataset(fil2)

xlat = getvar(file1,"lat")
xlon = getvar(file1,"lon")
lu = getvar(file1,"LU_INDEX")
T1 = getvar(file1,"T2",timeidx=ALL_TIMES)[trunc:trunc+dlen,:,:] -273.15
T2 = getvar(file2,"T2",timeidx=ALL_TIMES)[trunc:trunc+dlen,:,:] -273.15 #from 0:00 ~ 
alb1 = getvar(file1,"ALBEDO",timeidx=ALL_TIMES)[trunc:trunc+dlen,:,:]
alb2 = getvar(file2,"ALBEDO",timeidx=ALL_TIMES)[trunc:trunc+dlen,:,:]
swd1 = getvar(file1,"SWDOWN",timeidx=ALL_TIMES)[trunc:trunc+dlen,:,:]
swd2 = getvar(file2,"SWDOWN",timeidx=ALL_TIMES)[trunc:trunc+dlen,:,:]
TSK1 = getvar(file1,"TSK",timeidx=ALL_TIMES)[trunc:trunc+dlen,:,:] - 273.15
TSK2 = getvar(file2,"TSK",timeidx=ALL_TIMES)[trunc:trunc+dlen,:,:] - 273.15
#swu1 = alb1*swd1
#swu2 = alb2*swd2

u1 = getvar(file1,"U10",timeidx=ALL_TIMES)[trunc:trunc+dlen,:,:]
u2 = getvar(file2,"U10",timeidx=ALL_TIMES)[trunc:trunc+dlen,:,:]
v1 = getvar(file1,"V10",timeidx=ALL_TIMES)[trunc:trunc+dlen,:,:]
v2 = getvar(file2,"V10",timeidx=ALL_TIMES)[trunc:trunc+dlen,:,:]
q1 = getvar(file1,"Q2",timeidx=ALL_TIMES)[trunc:trunc+dlen,:,:]
q2 = getvar(file2,"Q2",timeidx=ALL_TIMES)[trunc:trunc+dlen,:,:]
cp1 = getvar(file1,"RAINNC",timeidx=ALL_TIMES)[trunc:trunc+dlen,:,:]+getvar(file1,"RAINC",timeidx=ALL_TIMES)[trunc:trunc+dlen,:,:]
cp2 = getvar(file2,"RAINNC",timeidx=ALL_TIMES)[trunc:trunc+dlen,:,:]+getvar(file2,"RAINC",timeidx=ALL_TIMES)[trunc:trunc+dlen,:,:]

wspd1 = (u1**2.+v1**2.)**0.5
wspd2 = (u2**2.+v2**2.)**0.5

d1 = len(xlat[:,0])
d2 = len(xlat[0,:])
dt = len(T2[:,0,0])

p1 = np.zeros((dt,d1,d2))
p2 = np.zeros((dt,d1,d2))


p1[0,:,:] = cp1[0,:,:]
p2[0,:,:] = cp2[0,:,:]


p1[1:,:,:] = cp1[1:,:,:]
p2[1:,:,:] = cp2[1:,:,:]

p1[1:,:,:] -= cp1[:dt-1,:,:]
p2[1:,:,:] -= cp2[:dt-1,:,:]


print(d1)
print(d2)

mut1 = np.zeros(dt)
mut2 = np.zeros(dt)
muw1 = np.zeros(dt)
muw2 = np.zeros(dt)
muu1 = np.zeros(dt)
muv1 = np.zeros(dt)
muu2 = np.zeros(dt)
muv2 = np.zeros(dt)
muq1 = np.zeros(dt)
muq2 = np.zeros(dt)
mup1 = np.zeros(dt)
mup2 = np.zeros(dt)
mswd1 = np.zeros(dt)
mswd2 = np.zeros(dt)
msts1 = np.zeros(dt)
msts2 = np.zeros(dt)

n = 0
for i in range(d1):
	for j in range(d2):
		if lu[i,j] == 13 or lu[i,j]>=31:
			mut1 += T1[:,i,j]
			mut2 += T2[:,i,j]
			muw1 += wspd1[:,i,j]
			muw2 += wspd2[:,i,j]
			muq1 += q1[:,i,j]
			muq2 += q2[:,i,j]
			muu1 += u1[:,i,j].values
			muv1 += v1[:,i,j].values
			muu2 += u2[:,i,j].values
			muv2 += v2[:,i,j].values
			mup1 += p1[:,i,j]
			mup2 += p2[:,i,j]
			mswd1 += swd1[:,i,j]
			mswd2 += swd2[:,i,j]
			msts1 += TSK1[:,i,j]
			msts2 += TSK2[:,i,j]
			n += 1
mut1 = mut1/float(n)
mut2 = mut2/float(n)
muw1 = muw1/float(n)
muw2 = muw2/float(n)
muq1 = muq1/float(n)
muq2 = muq2/float(n)
muu1 = muu1/float(n)
muv1 = muv1/float(n)
muu2 = muu2/float(n)
muv2 = muv2/float(n)
mup1 = mup1/float(n)
mup2 = mup2/float(n)
mswd1 = mswd1/float(n)
mswd2 = mswd2/float(n)
msts1 = msts1/float(n)
msts2 = msts2/float(n)

DIM = units.meter/units.second

uhi = mut2 - mut1

tday = int(dt/24)
maxut = np.full(tday,np.nan)
maxuhi = np.full(tday,np.nan)
maxw1 = np.full(tday,np.nan)
maxw2 = np.full(tday,np.nan)
maxq1 = np.full(tday,np.nan)
maxq2 = np.full(tday,np.nan)
maxu1 = np.full(tday,np.nan)
maxu2 = np.full(tday,np.nan)
maxv1 = np.full(tday,np.nan)
maxv2 = np.full(tday,np.nan)
mp1 = np.full(tday,np.nan)
mp2 = np.full(tday,np.nan)
maxswd1 = np.full(tday,np.nan)
maxswd2 = np.full(tday,np.nan)
maxts1 = np.full(tday,np.nan)
maxts2 = np.full(tday,np.nan)

for i in range(tday):
	maxut[i] = np.mean(mut1[24*i+5:24*i+20])
	maxuhi[i] = np.mean(uhi[24*i+5:24*i+20])
	maxw1[i] = np.mean(muw1[24*i+5:24*i+20])
	maxw2[i] = np.mean(muw2[24*i+5:24*i+20])
	maxu1[i] = np.mean(muu1[24*i+5:24*i+20])
	maxu2[i] = np.mean(muu2[24*i+5:24*i+20])
	maxv1[i] = np.mean(muv1[24*i+5:24*i+20])
	maxv2[i] = np.mean(muv2[24*i+5:24*i+20])
	maxq1[i] = np.mean(muq1[24*i+5:24*i+20])
	maxq2[i] = np.mean(muq2[24*i+5:24*i+20])
	mp1[i] = np.mean(mup1[24*i:24*i+24])
	mp2[i] = np.mean(mup2[24*i:24*i+24])
	maxswd1[i] = np.mean(mswd1[24*i+5:24*i+20])
	maxswd2[i] = np.mean(mswd2[24*i+5:24*i+20])
	maxts1[i] = np.mean(msts1[24*i+5:24*i+20])
	maxts2[i] = np.mean(msts2[24*i+5:24*i+20])

maxwd1 = np.array(wind_direction(maxu1*DIM,maxv1*DIM))
maxwd2 = np.array(wind_direction(maxu2*DIM,maxv2*DIM))

#maxuhi = np.delete(maxuhi,IND)
#maxwd = np.delete(maxwd,IND)
#maxut = np.delete(maxut,IND)
#maxw = np.delete(maxw,IND)
#maxq = np.delete(maxq,IND)

dl = len(maxuhi)

var = ['uhi','wd1','wd2','ut','wspd1','wspd2','q1','q2','p1','p2','swd1','swd2','tsk1']

varbox = np.full((len(var),dl),np.nan)


varbox[0,:] = maxuhi
varbox[1,:] = maxwd1
varbox[2,:] = maxwd2
varbox[3,:] = maxut
varbox[4,:] = maxw1
varbox[5,:] = maxw2
varbox[6,:] = maxq1
varbox[7,:] = maxq2
varbox[8,:] = mp1
varbox[9,:] = mp2
varbox[10,:] = maxswd1
varbox[11,:] = maxswd2
varbox[12,:] = maxts1


f = open(csvname,'w',newline='')
wr = csv.writer(f)
wr.writerow(var)
for i in range(dl):
	wr.writerow(varbox[:,i])

print(maxwd1)
print(maxut)
'''
xx = np.reshape(maxw,(-1,1))
#print(xx)

v1 = min(maxut)
v2 = max(maxut)
print(v1,v2)

model = LinearRegression()
model.fit(X=xx,y=maxuhi)
yyr = model.predict(xx)

mod = sm.OLS(maxuhi,maxw)
fii = mod.fit()
p_values = fii.summary2().tables[1]['P>|t|']
#print(p_values)
#print(fii.summary2().tables)
print(r2_score(maxuhi,yyr))

'''
sys.exit()

plt.figure(figsize=(6,6))
plt.scatter(maxwd1,maxuhi,c='k')
#plt.plot(xx,yyr,'k')
plt.xlabel('Daytime mean 10 m Wind Direction ($^\circ$C)')
plt.ylabel('Daytime mean White roof effect ($^\circ$C)')
plt.xticks(np.arange(0,361,step=90),[" ","E","S","W","N"])
#plt.yticks(np.arange(0,361,step=90),[" ","E","S","W","N"])
plt.savefig('./scatter_wd_day_T2_compare.png')
#plt.show()



