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

myFiles_raw = sorted(os.listdir(diro1))
myFiles = [file for file in myFiles_raw if file.endswith(".csv")]
print(myFiles)
filsiz = len(myFiles)
metadata = pd.read_csv(diro2+filo2,sep=',',header=None) # dtype = object ?

stn  = metadata[0]
#print(stn)
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


tDATE = sc.yymmdd(1973,1,1,2019,12,31)
vyear = np.zeros(ilen)
vmonth = np.zeros(ilen)
vday = np.zeros(ilen)


for i in range(ilen):
	vyear[i] = float(tDATE[i].split('-')[0])
	vmonth[i] = float(tDATE[i].split('-')[1])
	vday[i] = float(tDATE[i].split('-')[2])


#print(maT)

var = ['maT','meT','miT']


varsiz = len(var)

varbox = np.full((varsiz,nstn+3,ilen),np.nan)

varbox[0,0,:] = vyear
varbox[0,1,:] = vmonth
varbox[0,2,:] = vday
varbox[0,3:,:]  = maT
varbox[1,3:,:]  = meT
varbox[2,3:,:]  = miT

varbox[1,0,:] = varbox[0,0,:]
varbox[2,0,:] = varbox[0,0,:]
varbox[1,1,:] = varbox[0,1,:]
varbox[2,1,:] = varbox[0,1,:]
varbox[1,2,:] = varbox[0,2,:]
varbox[2,2,:] = varbox[0,2,:]

he = ["0" for i in range(nstn+3)]
he[0] = "year"
he[1] = "month"
he[2] = "day"
he[3:] = stn.values


for ii in range(varsiz):
	f = open('var_'+var[ii]+'.csv','w',newline='')
	wr = csv.writer(f)
	wr.writerow(he)
	for i in range(ilen):
		wr.writerow(varbox[ii,:,i])







