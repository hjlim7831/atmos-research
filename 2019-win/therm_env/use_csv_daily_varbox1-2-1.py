import sort_csv as sc
import time
import numpy as np
import pandas as pd
import csv
import os
#import sys

start = time.time()
print(start)

diro1 = '/home/hjlim/archive/CSV/ASOS_daily/'
diro2 = '~/2019-win/therm_env/csv/'

filo2 = 'META_ASOS_1973-2019_2020-02-17_revised.csv'

myFiles_raw = sorted(os.listdir(diro1))
myFiles = [file for file in myFiles_raw if file.endswith(".csv")]
print(myFiles)
filsiz = len(myFiles)
metadata = pd.read_csv(diro2+filo2,sep=',',header=None) # dtype = object ?

stn  = metadata[0]
mlat = metadata[1] #station처리는 stn자료를 미리 처리하고 이에 맞춰서 처리하기
mlon = metadata[2]
#print(stnnum)
nstn = len(stn)

data = pd.read_csv(diro1+myFiles[0],encoding='euc-kr')

#print(len(data.values[0]))
vsize = len(data.values[0]) -2
print("vsize:",vsize)

year = 1973

wDATE = sc.yymmdd(year,1,1,2019,12,31)
wlen = len(wDATE)


tdata = np.full((nstn,wlen,vsize),np.nan)

ilen = 0
for i in range(filsiz):
    tlen = 0
    
    if i < filsiz-1:
        ylen = 10
    else:
        ylen = 7
    print(year,"~",year+ylen-1)
    print(myFiles[i])
    
    for k in range(ylen):
        yr = k + year
        if sc.ly(yr):
            tlen += 366
        else:
            tlen += 365
    data1 = pd.read_csv(diro1+myFiles[i],encoding='euc-kr')
    stndata1 = data1['지점']
    date1 = data1['일시']
    rdata1 = data1.drop(['지점','일시'],axis=1)
    rd1 = rdata1.values
    sd1 = stndata1.values
    dd1 = date1.values

    b1 = sc.sep_csv(sd1,rd1,dd1)
	
    DATE1 = sc.yymmdd(year,1,1,year+ylen-1,12,31)

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
    year += 10

print("elapsed time: ",time.time() - start)
#print(tdata)

maT = tdata[:,:,3] #maximum Temperature
meT = tdata[:,:,0]
miT = tdata[:,:,1]
#print(maT)

HWind = np.zeros((nstn,ilen))
HWindex = np.zeros((nstn))

for i in range(nstn):
    for j in range(ilen-1):
        if maT[i,j] >= 33. and maT[i,j+1] >=33.:
            HWind[i,j] =1
            HWind[i,j+1] = 1
            
HWindex_2018 = np.nansum(HWind[:,ilen-730:ilen-365],axis=1)
print(sc.yymmdd(1973,1,1,2019,12,31)[ilen-730])
print(sc.yymmdd(1973,1,1,2019,12,31)[ilen-365])

HWindex = np.nansum(HWind,axis=1) / 47.

#print(HWindex)
#print(stn)

HWmaT = np.zeros((nstn))
HWmeT = np.zeros((nstn))
HWmiT = np.zeros((nstn))

#print(HWindex)
#print(HWindex_2018)

print(meT)
print(miT)

n = np.zeros((nstn))
for i in range(nstn):
	for j in range(ilen):
		if HWind[i,j] == 1 and not np.isnan(maT[i,j]):
			HWmaT[i] += maT[i,j]
			n[i] += 1.

for i in range(nstn):
	if n[i] != 0:
		HWmaT[i] = HWmaT[i]/n[i]
	else:
		HWmaT[i] = np.nan

n = np.zeros((nstn))
for i in range(nstn):
	for j in range(ilen):
		if HWind[i,j] == 1 and not np.isnan(meT[i,j]):
			HWmeT[i] += meT[i,j]
			n[i] += 1
for i in range(nstn):
	if n[i] != 0:
		HWmeT[i] = HWmeT[i]/n[i]
	else:
		HWmeT[i] = np.nan


n = np.zeros(nstn)
for i in range(nstn):
	for j in range(ilen):
		if HWind[i,j] == 1 and not np.isnan(miT[i,j]):
			HWmiT[i] += miT[i,j]
			n[i] += 1

for i in range(nstn):
	if n[i] != 0:
		HWmiT[i] = HWmiT[i]/n[i]
	else:
		HWmiT[i] = np.nan

HWmaT_2018 = np.zeros((nstn))
HWmeT_2018 = np.zeros((nstn))
HWmiT_2018 = np.zeros((nstn))


n = np.zeros((nstn))
for i in range(nstn):
    for j in range(ilen-730,ilen-365):
        if HWind[i,j] == 1 and not np.isnan(maT[i,j]):
            HWmaT_2018[i] += maT[i,j]
            n[i] += 1.

for i in range(nstn):
    if n[i] != 0:
        HWmaT_2018[i] = HWmaT_2018[i]/n[i]
    else:
        HWmaT_2018[i] = np.nan

n = np.zeros((nstn))
for i in range(nstn):
    for j in range(ilen-730,ilen-365):
        if HWind[i,j] == 1 and not np.isnan(meT[i,j]):
            HWmeT_2018[i] += meT[i,j]
            n[i] += 1

for i in range(nstn):
    if n[i] != 0:
        HWmeT_2018[i] = HWmeT_2018[i]/n[i]
    else:
        HWmeT_2018[i] = np.nan


n = np.zeros(nstn)
for i in range(nstn):
    for j in range(ilen-730,ilen-365):
        if HWind[i,j] == 1 and not np.isnan(miT[i,j]):
            HWmiT_2018[i] += miT[i,j]
            n[i] += 1


for i in range(nstn):
    if n[i] != 0.:
        HWmiT_2018[i] = HWmiT_2018[i]/n[i]
    else:
        HWmiT_2018[i] = np.nan

var = ['HWindex_2018','HWindex','HWindex_ano',\
		'HWmaT_2018','HWmaT','HWmaT_ano',\
		'HWmeT_2018','HWmeT','HWmeT_ano',\
		'HWmiT_2018','HWmiT','HWmiT_ano']

varsiz = len(var)

varbox = np.full((varsiz,nstn),np.nan)

varbox[0,:]  = HWindex_2018
varbox[1,:]  = HWindex
varbox[2,:]  = HWindex_2018 - HWindex
varbox[3,:]  = HWmaT_2018
varbox[4,:]  = HWmaT
varbox[5,:]  = HWmaT_2018 - HWmaT
varbox[6,:]  = HWmeT_2018
varbox[7,:]  = HWmeT
varbox[8,:]  = HWmeT_2018 - HWmeT
varbox[9,:]  = HWmiT_2018
varbox[10,:] = HWmiT
varbox[11,:] = HWmiT_2018 - HWmiT

f = open('varbox.csv','w',newline='')
wr = csv.writer(f)
wr.writerow(var)
for i in range(nstn):
	wr.writerow(varbox[:,i])





