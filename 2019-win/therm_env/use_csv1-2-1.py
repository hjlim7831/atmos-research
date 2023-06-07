import sort_csv as sc
import time
import numpy as np
import pandas as pd
import os
#import sys

start = time.time()
print(start)

diro1 = '/home/hjlim/archive/CSV/ASOS_hourly/'
diro2 = '~/2019-win/therm_env/csv/'

filo2 = 'META_ASOS_1973-2019_2020-02-17_revised.csv'

myFiles_raw = os.listdir(diro1)
myFiles = [file for file in myFiles_raw if file.endswith(".csv")]

filsiz = len(myFiles)
metadata = pd.read_csv(diro2+filo2,sep=',',header=None) # dtype = object ?

stn  = metadata[0]
mlat = metadata[1] #station처리는 stn자료를 미리 처리하고 이에 맞춰서 처리하기
mlon = metadata[2]
#print(stnnum)
nstn = len(stn)

data = pd.read_csv(diro1+myFiles[0],encoding='euc-kr')

#print(len(data.values[0]))
vsize = len(data.values[0]) -3

year = 1973

wDATE = sc.yymmddhh(year,1,1,2019,12,31)
wlen = len(wDATE)


tdata = np.full((nstn,wlen,vsize),np.nan)

ilen = 0
for i in range(filsiz):

	print(year)
	if sc.ly(year):
		tlen = 366*24
	else:
		tlen = 365*24
	data1 = pd.read_csv(diro1+myFiles[i],encoding='euc-kr')
	stndata1 = data1['지점']
	date1 = data1['일시']
	rdata1 = data1.drop(['지점','일시','운형(운형약어)'],axis=1)
	rd1 = rdata1.values
	sd1 = stndata1.values
	dd1 = date1.values

	b1 = sc.sep_csv(sd1,rd1,dd1)
	
	DATE1 = sc.yymmddhh(year,1,1,year,12,31)

	b1.date_csv(DATE1)
	gdata1 = b1.gdata

	stnnum1 = b1.stnnum
#stn 걸러내는 작업 필요
#stn, stnnum, 을 이용해야..

#	dummy = np.full(nstn,np.nan)
	mdata1_r = np.full((nstn,b1.dsize,b1.vsize),np.nan)
	n = 0
	for j in range(tlen):
		if n < nstn:
			if stnnum1[j] == stn[n]:
				mdata1_r[n,:,:] = gdata1[j,:,:]
#				dummy[n] = stnnum1[j]
				n += 1
#	print(dummy)
	
	tdata[:,ilen:ilen+tlen,:] = mdata1_r

	ilen += tlen
	year += 1

print("elapsed time: ",time.time() - start)
#print(tdata)

mT = tdata[:,:,0]  #hourly data
#print(mT)

HWind = np.zeros((nstn,tlen))
HWindex = np.zeros((nstn))

for i in range(nstn):
	for j in range(tlen-1):
		if mT[i,j] >= 33. and mT[i,j+1] >=33.:
			HWind[i,j] =1
			HWind[i,j+1] = 1
            
HWindex = np.nanmean(HWind,axis=1)


print(HWindex)
print(b.stnnum)

for i in range(nstn):
    for j in range(tlen):
        if mT[i,j]


