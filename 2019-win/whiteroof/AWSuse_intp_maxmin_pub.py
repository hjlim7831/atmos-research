import sort_csv as sc
import wrf_intp as wi
import pandas as pd
import numpy as np
import matplotlib.pyplot as plt
import matplotlib.dates as dates
import datetime
import sys
from matplotlib import font_manager as fm, rcParams
from matplotlib.ticker import AutoMinorLocator, MultipleLocator
from matplotlib import rc
from metpy.calc import wind_direction
from metpy.units import units

font_dirs = ['/home/hjlim/archive/font/',]
font_files = fm.findSystemFonts(fontpaths=font_dirs)
font_list = fm.createFontList(font_files)
fm.fontManager.ttflist.extend(font_list)
rcParams['font.family'] = 'Helvetica'
rcParams['axes.linewidth'] = 1.2
rcParams['mathtext.fontset'] = 'custom'
rcParams['mathtext.rm'] = 'Helvetica'
rcParams['mathtext.it'] = 'Helvetica'
rcParams['mathtext.bf'] = 'Helvetica'


diri1 = '~/2019-win/whiteroof/'
diri2 = 'csv/'
dim = 28
sday = 15
trunc1 = 3
trunc2 = 0
dlen = 891-trunc1-trunc2

sdt = (sday - 15)*24 # for ASOS data

fil1 = 'e2wrfout_d03_2018-07-14_12:00:00'
fil2 = 'AWS_stninfo_0715-0820_seoul_revised.csv'
fil3 = 'AWS_0715-0820_forValid_revised.csv'
metadata = pd.read_csv(diri1+diri2+fil2,sep=',',header=None)
stnnum = metadata[0]
mlat = np.array(metadata[1])
mlon = np.array(metadata[2])

ti1 = "CR Case"
idx = pd.date_range("2018-07-15 00:00:00",periods=dlen,freq='H')

interpT = wi.intp_valid(fil1,mlat,mlon,"T2")[:,sdt+trunc1:sdt+dlen+trunc1] -273.15

vdata = pd.read_csv(diri1+diri2+fil3,sep=',',header=None)
stndata = vdata[0]
date = vdata[1]
rdata = vdata.drop([0,1],axis=1)
rd = rdata.values
sd = stndata.values
dd = date.values
b = sc.sep_csv(sd,rd,dd)


DATE = sc.yymmddhh(2018,7,15,2018,8,20)
b.date_csv(DATE)
gdata = b.gdata[:,sdt:dlen+sdt,:]
#print(DATE[sdt:dlen+sdt])

print(gdata.shape)
print(interpT.shape)
## gdata, interpT, interpU, interpV

d1 = len(gdata[:,0,0])
d2 = len(gdata[0,:,0])


mdataT = interpT.reshape(dim*dlen)
odataT = gdata[:,:,0].reshape(dim*dlen)

tlen = int(dlen/24)


oMdataT_1 = np.full((tlen*dim),np.nan)
mMdataT_1 = np.full((tlen*dim),np.nan)
omdataT_1 = np.full((tlen*dim),np.nan)
mmdataT_1 = np.full((tlen*dim),np.nan)


tlen = int(dlen/24)

#1) 관측값 기준
for i in range(tlen*dim):
	arr = odataT[24*i:24*(i+1)]
	arr2 = mdataT[24*i:24*(i+1)]
	tt = 0.
	ii = 0
	for j in range(24):
		if arr[j] > tt:
			tt = arr[j]
			ii = j
#			print(ii)
	if tt == 0.:
		oMdataT_1[i] = np.nan
		mMdataT_1[i] = np.nan
	else:
		oMdataT_1[i] = tt
		mMdataT_1[i] = arr2[ii]
	tt = 300.
	ii = 0
	for k in range(24):
		if arr[k] <tt:
			tt = arr[k]
			ii = k
	if tt == 300.:
		omdataT_1[i] = np.nan
		mmdataT_1[i] = np.nan
	else:
		omdataT_1[i] = tt
		mmdataT_1[i] = arr2[ii]


print(oMdataT_1)
print(omdataT_1)

print(max(omdataT_1))
print(min(omdataT_1))
print(max(oMdataT_1))
print(min(oMdataT_1))


n1 = 0
n2 = 0
VAR = 0.
ME = 0.
MAE = 0.
for i in range(tlen*dim):
    if pd.notnull(oMdataT_1[i]):
        diff = mMdataT_1[i] - oMdataT_1[i]
        VAR += diff**2
        ME += diff
        MAE += abs(diff)
        n1 += 1
        if diff<=2. and diff>=-2:
            n2 += 1

HRT_M = float(n2)/float(n1) * 100
RMSE = (VAR/float(n1))**0.5
MAE = MAE/float(n1)
ME = ME/float(n1)

print("Hit rate of maxT2 = {}".format(HRT_M))
print("RMSE of maxT2 = {}".format(RMSE))
print("Mean error of maxT2 = {}".format(ME))
print("Mean absolute error of T2 = {}".format(MAE))


n1 = 0
n2 = 0
VAR = 0.
ME = 0.
MAE = 0.
for i in range(tlen*dim):
    if pd.notnull(omdataT_1[i]):
        diff = mmdataT_1[i] - omdataT_1[i]
        VAR += diff**2
        ME += diff
        MAE += abs(diff)
        n1 += 1
        if diff<=2. and diff>=-2:
            n2 += 1

HRT_m = float(n2)/float(n1) * 100
RMSE = (VAR/float(n1))**0.5
ME = ME/float(n1)
MAE = MAE/float(n1)

print("Hit rate of minT2 = {}".format(HRT_m))
print("RMSE of minT2 = {}".format(RMSE))
print("Mean error of minT2 = {}".format(ME))
print("Mean absolute error of WS = {}".format(MAE))


RMSE_M = np.sqrt((np.mean(np.square(oMdataT_1-mMdataT_1))))
RMSE_m = np.sqrt((np.mean(np.square(omdataT_1-mmdataT_1))))




#scatter option
siz = 5
colr = 'b'
fsiz = 11

#plot T2
sy1 = 25
ey1 = 45
sy2 = 15
ey2 = 35
sy3 = -6
ey3 = 366

fig, ax = plt.subplots(ncols = 2, nrows = 1,figsize=(8.5,4))

ax[0].scatter(oMdataT_1,mMdataT_1,c='k',s=siz)
ax[0].plot([sy1,ey1],[sy1,ey1],'k')
ax[0].set_xlim(sy1,ey1)
ax[0].set_ylim(sy1,ey1)
ax[0].set_xlabel('Observed Daily Maximum Temperature ($^\circ$C)',fontsize=fsiz)
ax[0].set_ylabel('Simulated Temperature at t* ($^\circ$C)',fontsize=fsiz)

ax[1].scatter(omdataT_1,mmdataT_1,c='k',s=siz)
ax[1].plot([sy2,ey2],[sy2,ey2],'k')
ax[1].set_xlim(sy2,ey2)
ax[1].set_ylim(sy2,ey2)
ax[1].set_xlabel('Observed Daily Minimum Temperature ($^\circ$C)',fontsize=fsiz)
ax[1].set_ylabel('Simulated Temperature at t** ($^\circ$C)',fontsize=fsiz)



#plt.show()
plt.savefig('./tempmaxmin_valid.png',bbox_inches='tight')






