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

filo2 = 'META_ASOS_1973-2019_2020-02-17_revisedv2.csv'

wantyear = 1978

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

eDATE = sc.yymmdd(datayear,1,1,wantyear,12,31)

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

maT = np.nanmean(tdata[:,:,3],axis=0) #maximum Temperature
meT = np.nanmean(tdata[:,:,0],axis=0)
miT = np.nanmean(tdata[:,:,1],axis=0)
#print(maT)

maT78 = np.full(62*41,np.nan)
meT78 = np.full(62*41,np.nan)
miT78 = np.full(62*41,np.nan)

n = 0
for j in range(ilen):
	mo = wDATE[j].split("-")[1]
	if mo == "07" or mo == "08":
		maT78[n] = maT[j]
		meT78[n] = meT[j]
		miT78[n] = miT[j]
		n += 1
varbox = np.full((62*41,3),np.nan)

varbox[:,0] = maT78
varbox[:,1] = meT78
varbox[:,2] = miT78

f = open('cseof.csv','w',newline='')
wr = csv.writer(f)
wr.writerow(['maT','meT','miT'])
for i in range(62*41):
	wr.writerow(varbox[i,:])





