import sort_csv as sc
import numpy as np
import pandas as pd

diri = '~/2019-win/whiteroof/csv/'
fil1 = 'ASOS_0715-0820_forValid_revised.csv'
fil2 = 'AWS_0715-0820_forValid_revised.csv'

fil3 = 'AWS_stninfo_0715-0820_seoul_revised.csv'

asosdata = pd.read_csv(diri+fil1,sep=',',header=None) # temp, wsp, wd
awsdata = pd.read_csv(diri+fil2,sep=',',header=None) # temp, wd, wsp

stndata = pd.read_csv(diri+fil3,sep=',',header=None) # lat, lon

stndata1 = asosdata[0]
date1 = asosdata[1]
rdata1 = asosdata.drop([0,1],axis=1)
#print(stndata1)
#print(rdata1)
#print(date1)
rd1 = rdata1.values
sd1 = stndata1.values
dd1 = date1.values

b1 = sc.sep_csv(sd1,rd1,dd1)
rdate1 = b1.rdate
mdata1 = b1.mdata
#print(rdate1)
#print(mdata1)
#b1.yymmddhh(2018,7,15,2018,8,20)

DATE1 = sc.yymmddhh(2018,7,15,2018,8,20)
tlen1 = len(DATE1)

b1.date_csv(DATE1)
gdata1 = b1.gdata
print(gdata1)









