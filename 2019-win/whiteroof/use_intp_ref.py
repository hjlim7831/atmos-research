import sort_csv as sc
import wrf_intp as wi
import pandas as pd
import numpy as np
import matplotlib.pyplot as plt
from metpy.calc import wind_direction
from metpy.units import units

diri1 = '~/2019-win/whiteroof/'
diri2 = 'csv/'
dim = 1
dlen = 360


#fil1 = 'geo_em.d03.nc'
fil1 = 'wrfout_d04_2018-07-26_12:00:00'
fil3 = 'ASOS_0715-0820_forValid_revised.csv'
mlat = np.array([37.5714])
mlon = np.array([126.9658])

interpT = wi.intp_valid(fil1,mlat,mlon,"T2")[3*6:2196-3*6:6] -273.15
interpU = wi.intp_valid(fil1,mlat,mlon,"U10")[3*6:2196-3*6:6]
interpV = wi.intp_valid(fil1,mlat,mlon,"V10")[3*6:2196-3*6:6]

DIM = units.meter/units.second
#print(interpT.shape)

vdata = pd.read_csv(diri1+diri2+fil3,sep=',',header=None)
stndata = vdata[0]
date = vdata[1]
rdata = vdata.drop([0,1],axis=1)
rd = rdata.values
sd = stndata.values
dd = date.values
b = sc.sep_csv(sd,rd,dd)


b.yymmddhh(2018,7,15,2018,8,20)
b.date_csv()
DATE = b.DATE[24*(27-15):24*(36-9)]
#print(DATE)
gdata = b.gdata[24*(27-15):24*(36-9),:]

print(gdata.shape)
print(interpT.shape)
## gdata, interpT, interpU, interpV

interpws = (interpU**2.+interpV**2.)**0.5

interpwd = wind_direction(interpU*DIM,interpV*DIM)

mdataT = interpT.reshape(dim*dlen)
odataT = gdata[:,0].reshape(dim*dlen)

n1 = 0
n2 = 0
VAR = 0.
ME = 0.
for i in range(dim*dlen):
	if pd.notnull(odataT[i]):
		diff = mdataT[i] - odataT[i]
		VAR += diff**2
		ME += diff
		n1 += 1
		if diff<=2. and diff>=-2:
			n2 += 1
#	else:
#		print(odataT[i])
RMSE = (VAR/float(n1))
ME = ME/float(n1)
HRT = float(n2)/float(n1) *100

print("Hit rate of T2 = {}".format(HRT))
print("RMSE of T2 = {}".format(RMSE))
print("Mean error of T2 = {}".format(ME))

mdataws = interpws.reshape(dim*dlen)
odataws = gdata[:,1].reshape(dim*dlen)

n1 = 0
n2 = 0
VAR = 0.
ME = 0.
for i in range(dim*dlen):
    if pd.notnull(odataws[i]):
        diff = mdataws[i] - odataws[i]
        VAR += diff**2
        ME += diff
        n1 += 1
        if diff<=2. and diff>=-2:
            n2 += 1

RMSE = (VAR/float(n1))
ME = ME/float(n1)
HRT = float(n2)/float(n1) *100

print("RMSE of wind speed = {}".format(RMSE))
print("Mean error of wind speed = {}".format(ME))


#plot T2
sx = 18
ex = 42

plt.figure(figsize=(6,6))
plt.xlim(sx,ex)
plt.ylim(sx,ex)
plt.title('air temperature observed vs REAL')
plt.xlabel('observed temperature ($^\circ$C)')
plt.ylabel('simulated 2 m temperature ($^\circ$C)')
plt.scatter(odataT,mdataT,s=1)
plt.plot([sx,ex],[sx,ex],'k')
#plt.show()
plt.savefig('./reftemp_valid.png',bbox_inches='tight')

plt.figure(figsize=(20,3))
plt.title('air temperature observed vs REAL')
plt.xlim(0,360)
plt.xlabel('elapsed time(hr)')
plt.ylabel('2 m temperature ($^\circ$C)')
plt.scatter([i for i in range(dlen)],odataT,s=0.5,label='OBS')
plt.scatter([i for i in range(dlen)],mdataT,s=0.5,label='REAL')
plt.legend()
#plt.show()
plt.savefig('./reftemp_series.png',bbox_inches='tight')


#plot wind speed
sx = 0
ex = 7

plt.figure(figsize=(6,6))
plt.title('10 m windspeed observed vs REAL')
plt.xlabel('observed windspeed(m/s)')
plt.ylabel('simulated 10 m windspeed(m/s)')
plt.scatter(odataws,mdataws,s=1)
plt.xlim(sx,ex)
plt.ylim(sx,ex)
plt.plot([sx,ex],[sx,ex],'k')
#plt.show()
plt.savefig('./refws_valid.png',bbox_inches='tight')

plt.figure(figsize=(20,3))
plt.title('10 m windspeed observed vs REAL')
plt.xlim(0,360)
plt.xlabel('elapsed time(hr)')
plt.ylabel('10 m windspeed(m/s)')
plt.scatter([i for i in range(dlen)],odataws,s=0.5,label='OBS')
plt.scatter([i for i in range(dlen)],mdataws,s=0.5,label='REAL')
plt.legend()
#plt.show()
plt.savefig('./refws_series.png',bbox_inches='tight')



#plot wind direction
sx = 0
ex = 360

mdatawd = interpwd.reshape(dim*dlen)
odatawd = gdata[:,2].reshape(dim*dlen)

plt.figure(figsize=(6,6))
plt.title('10 m wind direction observed vs REAL')
plt.xlabel('observed wind direction ($^\circ$)')
plt.ylabel('simulated 10 m wind direction ($^\circ$)')
plt.scatter(odatawd,mdatawd,s=1)
plt.xlim(sx,ex)
plt.ylim(sx,ex)
plt.xticks(np.arange(0,361,step=90))
plt.yticks(np.arange(0,361,step=90))
plt.plot([sx,ex],[sx,ex],'k')
#plt.show()
plt.savefig('./refwd_valid.png',bbox_inches='tight')

plt.figure(figsize=(20,3))
plt.title('10 m wind direction observed vs REAL')
plt.xlim(0,360)
plt.xlabel('elapsed time(hr)')
plt.ylabel('10 m wind direction ($^\circ$)')
plt.yticks(np.arange(0,361,step=90))
plt.scatter([i for i in range(dlen)],odatawd,s=0.5,label='OBS')
plt.scatter([i for i in range(dlen)],mdatawd,s=0.5,label='REAL')
plt.legend()
#plt.show()
plt.savefig('./refwd_series.png',bbox_inches='tight')





