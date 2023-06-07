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

wantyear = 1979

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

datayear = 1973

rwDATE = sc.yymmdd(datayear,1,1,2019,12,31)
wlen = len(rwDATE)
#print(rwDATE)

eDATE = sc.yymmdd(datayear,1,1,wantyear-1,12,31)

aa = len(eDATE)

rtdata = np.full((nstn,wlen,vsize),np.nan)

ilen = 0
for i in range(filsiz):
    tlen = 0
    
    if i < filsiz-1:
        ylen = 10
    else:
        ylen = 7
    print(datayear,"~",datayear+ylen-1)
    print(myFiles[i])
    
    for k in range(ylen):
        yr = k + datayear
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
	
    DATE1 = sc.yymmdd(datayear,1,1,datayear+ylen-1,12,31)

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
	
    rtdata[:,ilen:ilen+tlen,:] = mdata1_r

    ilen += tlen
    datayear += 10

tdata = rtdata[:,aa:,:]
wDATE = rwDATE[aa:]

ilen = ilen - aa


print("elapsed time: ",time.time() - start)
#print(tdata)

maT = tdata[:,:,3] #maximum Temperature
meT = tdata[:,:,0]
miT = tdata[:,:,1]
mir = tdata[:,:,21]
mer = tdata[:,:,23]
#print(maT)

HWmaT = np.zeros((nstn))
HWmeT = np.zeros((nstn))
HWmiT = np.zeros((nstn))
HWmir = np.zeros((nstn))
HWmer = np.zeros((nstn))

HWind = np.zeros((nstn,ilen))
HWindex = np.zeros((nstn))


for i in range(nstn):
    for j in range(ilen-1):
        if maT[i,j] >= 33. and maT[i,j+1] >=33.:
            HWind[i,j] =1
            HWind[i,j+1] = 1

HWind78 = np.zeros((nstn,ilen))

meanmaT = 0.
man = 0.

for i in range(nstn):
	for j in range(ilen-1):
		mo = wDATE[j].split("-")[1]
		if mo == "07" or mo == "08":
			if maT[i,j] >= 33. and maT[i,j+1] >= 33.:
				HWind78[i,j] = 1
				HWind78[i,j+1] = 1

print(np.nansum(HWind))
print(np.nansum(HWind78))

for i in range(nstn):
	for j in range(ilen):
		mo = wDATE[j].split("-")[1]
		if mo == "07" or mo == "08":
			if not np.isnan(maT[i,j]):
				meanmaT += maT[i,j]
				print(maT[i,j])
				man += 1.


print(meanmaT/man)

HWD = np.nanmean(maT,axis=0)

maT18 = maT[:,ilen-730:ilen-365]
HWD18 = HWD[ilen-730:ilen-365]
wDATE18 = wDATE[ilen-730:ilen-365]

HWmaxT = np.zeros(nstn)
nHWmaxT = np.zeros(nstn)

#crit = 29.4
crit = 33.

n1, n2 = 0, 0
for j in range(365):
	mo = wDATE18[j].split("-")[1]
	if mo == "07" or mo == "08":
		if HWD18[j] >=crit:
			HWmaxT[:] += maT18[:,j]
			n1 += 1
		else:
			nHWmaxT[:] += maT18[:,j]
			n2 += 1
HWmaxT = HWmaxT/float(n1)
nHWmaxT = nHWmaxT/float(n2)

print(n1,n2)

varbox2 = np.full((2,nstn),np.nan)
varbox2[0,:] = HWmaxT
varbox2[1,:] = nHWmaxT

ff = open('hw_nhw.csv','w',newline='')
wr2 = csv.writer(ff)
wr2.writerow(['HWmaxT','nHWmaxT'])
for i in range(nstn):
	wr2.writerow(varbox2[:,i])


HWindex_2018 = np.nansum(HWind[:,ilen-730:ilen-365],axis=1)
HWindex = np.nansum(HWind,axis=1) / (2019-wantyear+1)

print(ilen)

print(sc.yymmdd(wantyear,1,1,2019,12,31)[ilen-730])
print(sc.yymmdd(wantyear,1,1,2019,12,31)[ilen-365])

f1 = open('heatwave.csv','w',newline='')
wr = csv.writer(f1)
for i in range(ilen):
	wr.writerow([HWD[i]])

print(HWD)

nn1 = 0
nn2 = 0
for i in range(ilen):
	if HWD[i] >=crit:
		nn1 += 1
	if ilen-730<i<ilen-365 and HWD[i] >crit:
		nn2 += 1

print(nn1)
print(nn2)

n = np.zeros((nstn))
for i in range(nstn):
	for j in range(ilen):
		if HWD[j] >=crit and not np.isnan(maT[i,j]):
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
		if HWD[j] >= crit and not np.isnan(meT[i,j]):
			HWmeT[i] += meT[i,j]
			n[i] += 1

for i in range(nstn):
	if n[i] != 0:
		HWmeT[i] = HWmeT[i]/n[i]
	else:
		HWmeT[i] = np.nan

n = np.zeros((nstn))
for i in range(nstn):
	for j in range(ilen):
		if HWD[j] >= crit and not np.isnan(miT[i,j]):
			HWmiT[i] += miT[i,j]
			n[i] += 1

for i in range(nstn):
	if n[i] != 0:
		HWmiT[i] = HWmiT[i]/n[i]
	else:
		HWmiT[i] = np.nan

n = np.zeros((nstn))
for i in range(nstn):
	for j in range(ilen):
		if HWD[j] >= crit and not np.isnan(mer[i,j]):
			HWmer[i] += mer[i,j]
			n[i] += 1

for i in range(nstn):
	if n[i] != 0:
		HWmer[i] = HWmer[i]/n[i]
	else:
		HWmer[i] = np.nan

n = np.zeros((nstn))
for i in range(nstn):
	for j in range(ilen):
		if HWD[j] >= crit and not np.isnan(mir[i,j]):
			HWmir[i] += mir[i,j]
			n[i] += 1

for i in range(nstn):
	if n[i] != 0:
		HWmir[i] = HWmir[i]/n[i]
	else:
		HWmir[i] = np.nan


HWmaT_2018 = np.zeros((nstn))
HWmeT_2018 = np.zeros((nstn))
HWmiT_2018 = np.zeros((nstn))
HWmir_2018 = np.zeros((nstn))
HWmer_2018 = np.zeros((nstn))

n = np.zeros((nstn))
for i in range(nstn):
    for j in range(ilen-730,ilen-365):
        if HWD[j] >= crit and not np.isnan(maT[i,j]):
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
        if HWD[j] >= crit and not np.isnan(meT[i,j]):
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
        if HWD[j] >= crit and not np.isnan(miT[i,j]):
            HWmiT_2018[i] += miT[i,j]
            n[i] += 1


for i in range(nstn):
    if n[i] != 0.:
        HWmiT_2018[i] = HWmiT_2018[i]/n[i]
    else:
        HWmiT_2018[i] = np.nan

n = np.zeros(nstn)
for i in range(nstn):
    for j in range(ilen-730,ilen-365):
        if HWD[j] >= crit and not np.isnan(mir[i,j]):
            HWmir_2018[i] += mir[i,j]
            n[i] += 1


for i in range(nstn):
    if n[i] != 0.:
        HWmir_2018[i] = HWmir_2018[i]/n[i]
    else:
        HWmir_2018[i] = np.nan

n = np.zeros(nstn)
for i in range(nstn):
    for j in range(ilen-730,ilen-365):
        if HWD[j] >= crit and not np.isnan(mer[i,j]):
            HWmer_2018[i] += mer[i,j]
            n[i] += 1


for i in range(nstn):
    if n[i] != 0.:
        HWmer_2018[i] = HWmer_2018[i]/n[i]
    else:
        HWmer_2018[i] = np.nan



var = ['HWindex_2018','HWindex','HWindex_ano',\
		'HWmaT_2018','HWmaT','HWmaT_ano',\
		'HWmeT_2018','HWmeT','HWmeT_ano',\
		'HWmiT_2018','HWmiT','HWmiT_ano',\
		'HWmer_2018','HWmer','HWmer_ano',\
		'HWmir_2018','HWmir','HWmir_ano']


varsiz = len(var)

varbox = np.full((varsiz,nstn),np.nan)

varbox[0,:] = HWindex_2018
varbox[1,:] = HWindex
varbox[2,:] = varbox[0,:] - varbox[1,:]
varbox[3,:] = HWmaT_2018
varbox[4,:] = HWmaT
varbox[5,:] = varbox[3,:] - varbox[4,:]
varbox[6,:] = HWmeT_2018
varbox[7,:] = HWmeT
varbox[8,:] = varbox[6,:] - varbox[7,:]
varbox[9,:] = HWmiT_2018
varbox[10,:] = HWmiT
varbox[11,:] = varbox[9,:] - varbox[10,:]
varbox[12,:] = HWmer_2018
varbox[13,:] = HWmer
varbox[14,:] = varbox[12,:] - varbox[13,:]
varbox[15,:] = HWmir_2018
varbox[16,:] = HWmir
varbox[17,:] = varbox[15,:] - varbox[16,:]


"""
varbox[0,:] = HWindex_2018
varbox[1,:] = HWindex
varbox[2,:] = varbox[0,:] - varbox[1,:]
varbox[3,:] = np.nanmean(HWmaT_2018,axis=1)
varbox[4,:] = np.nanmean(HWmaT,axis=1)
varbox[5,:] = varbox[3,:] - varbox[4,:]
varbox[6,:] = np.nanmean(HWmiT_2018,axis=1)
varbox[7,:] = np.nanmean(HWmiT,axis=1)
varbox[8,:] = varbox[6,:] - varbox[7,:]
"""

f = open('varboxv8.csv','w',newline='')
wr = csv.writer(f)
wr.writerow(var)
for i in range(nstn):
	wr.writerow(varbox[:,i])





