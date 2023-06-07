import sort_csv as sc
import wrf_intp as wi
import pandas as pd
import numpy as np
import matplotlib.pyplot as plt
import matplotlib.dates as dates
from metpy.calc import wind_direction
from metpy.units import units

diri1 = '~/2019-win/whiteroof/'
diri2 = 'csv/'
dim = 1
sday = 21
#dlen = 737
dlen = 171-3

#sday = 21
#dlen = 24*7

sdt = (sday - 15)*24 # for ASOS data

#fil1 = 'cwrfout_d03_2018-07-14_12:00:00'
fil1 = 'g1wrfout_d03_2018-07-20_12:00:00'
#fil2 = 'g16wrfout_d04_2018-07-20_12:00:00'
fil2 = 'kfg1wrfout_d03_2018-07-20_12:00:00'
fil3 = 'ASOS_0715-0820_forValid_revised.csv'
mlat = np.array([37.5714])
mlon = np.array([126.9658])

ti1 = "KF ON"
ti2 = "KF OFF"
idx = pd.date_range("2018-07-21 00:00:00",periods=dlen,freq='H')

interpT = wi.intp_valid(fil1,mlat,mlon,"T2")[3:dlen+3] -273.15
interpU = wi.intp_valid(fil1,mlat,mlon,"U10")[3:dlen+3]
interpV = wi.intp_valid(fil1,mlat,mlon,"V10")[3:dlen+3]
interpT2 = wi.intp_valid(fil2,mlat,mlon,"T2")[3:dlen+3] -273.15
interpU2 = wi.intp_valid(fil2,mlat,mlon,"U10")[3:dlen+3]
interpV2 = wi.intp_valid(fil2,mlat,mlon,"V10")[3:dlen+3]


print(interpT.shape)

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


DATE = sc.yymmddhh(2018,7,15,2018,8,20)
b.date_csv(DATE)
gdata = b.gdata[sdt:dlen+sdt,:]
print(DATE[sdt:dlen+sdt])

print(gdata.shape)
print(interpT.shape)
## gdata, interpT, interpU, interpV

interpws = (interpU**2.+interpV**2.)**0.5
interpws2 = (interpU2**2.+interpV2**2.)**0.5

interpwd = wind_direction(interpU*DIM,interpV*DIM)
interpwd2 = wind_direction(interpU2*DIM,interpV2*DIM)

mdataT = interpT.reshape(dim*dlen)
mdataT2 = interpT2.reshape(dim*dlen)
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
RMSE = (VAR/float(n1))**0.5
ME = ME/float(n1)
HRT = float(n2)/float(n1) *100

print("Hit rate of T2 = {}".format(HRT))
print("RMSE of T2 = {}".format(RMSE))
print("Mean error of T2 = {}".format(ME))

mdataws = interpws.reshape(dim*dlen)
mdataws2 = interpws2.reshape(dim*dlen)
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

RMSE = (VAR/float(n1))**0.5
ME = ME/float(n1)
HRT = float(n2)/float(n1) *100

print("RMSE of wind speed = {}".format(RMSE))
print("Mean error of wind speed = {}".format(ME))

mdatawd = interpwd.reshape(dim*dlen)
mdatawd2 = interpwd2.reshape(dim*dlen)
odatawd = gdata[:,2].reshape(dim*dlen)

#scatter option
siz = 3
colr = 'b'

#plot T2
sy1 = 18
ey1 = 42
sy2 = -0.2
ey2 = 7
sy3 = -6
ey3 = 366

plt.figure(figsize=(6,6))
plt.xlim(sy1,ey1)
plt.ylim(sy1,ey1)
plt.title('air temperature observed vs REAL')
plt.xlabel('observed temperature ($^\circ$C)')
plt.ylabel('simulated 2 m temperature ($^\circ$C)')
plt.scatter(odataT,mdataT,s=siz,color=colr)
plt.plot([sy1,ey1],[sy1,ey1],'k')
#plt.show()
plt.savefig('./temp_valid.png',bbox_inches='tight')

lw = 1.5
ms = 3.

fig, ax = plt.subplots(ncols = 1, nrows = 3,sharex=True,figsize=(12,7))
ax[0].plot_date(idx.to_pydatetime(),mdataT,'bv-',markersize=ms,linewidth=lw,label=ti1)
ax[0].plot_date(idx.to_pydatetime(),mdataT2,'rv-',markersize=ms,linewidth=lw,label=ti2)
ax[0].plot_date(idx.to_pydatetime(),odataT,'ko',markersize=ms,linewidth=lw,label='OBS')
ax[0].plot_date(idx.to_pydatetime(),[33 for i in range(dlen)],'k-')
#ax[0].xaxis.grid(True, which="minor",linestyle='--')
ax[0].xaxis.grid(True, color='k',which="major")
ax[0].yaxis.grid()
ax[0].set_ylabel('2 m temperature ($^\circ$C)')
ax[0].legend(loc='upper left')
ax[0].set_ylim(sy1,ey1)
ax[1].plot_date(idx.to_pydatetime(),mdataws,'bv-',markersize=ms,linewidth=lw,label=ti1)
ax[1].plot_date(idx.to_pydatetime(),mdataws2,'rv-',markersize=ms,linewidth=lw,label=ti2)
ax[1].plot_date(idx.to_pydatetime(),odataws,'ko',markersize=ms,linewidth=lw,label='OBS')
#ax[1].xaxis.grid(True, which="minor",linestyle='--')
ax[1].xaxis.grid(True, color='k',which="major")
ax[1].yaxis.grid()
ax[1].set_ylabel('10 m windspeed(m/s)')
ax[1].set_ylim(sy2,ey2)
ax[2].plot_date(idx.to_pydatetime(),mdatawd,'bv',markersize=ms,linewidth=lw,label=ti1)
ax[2].plot_date(idx.to_pydatetime(),mdatawd2,'rv',markersize=ms,linewidth=lw,label=ti2)
ax[2].plot_date(idx.to_pydatetime(),odatawd,'ko',markersize=ms,linewidth=lw,label='OBS')
#ax[2].xaxis.set_major_locator(dates.WeekdayLocator(byweekday=(1),interval=1))
ax[2].xaxis.set_major_locator(dates.DayLocator())

ax[2].xaxis.set_major_formatter(dates.DateFormatter('%b %d'))
ax[2].xaxis.set_minor_locator(dates.DayLocator())
#ax[2].xaxis.grid(True, which="minor",linestyle='--')
ax[2].xaxis.grid(True, color='k',which="major")
ax[2].yaxis.grid()
ax[2].set_xlabel('2018')
ax[2].set_yticks(np.arange(0,361,step=90))
ax[2].set_ylabel('10 m wind direction ($^\circ$)')
ax[2].set_ylim(sy3,ey3)
plt.tight_layout()
plt.savefig('./valid_series.png',bbox_inches='tight')
#plt.show()

"""
plt.figure(figsize=(20,3))
plt.title('air temperature observed vs REAL')
plt.xlim(0,dlen)
plt.xlabel('elapsed time(hr)')
plt.ylabel('2 m temperature ($^\circ$C)')
#plt.scatter([i for i in range(dlen)],odataT,s=0.5,label='OBS')
#plt.scatter([i for i in range(dlen)],mdataT,s=0.5,label='REAL')
plt.plot([i for i in range(dlen)],odataT,label='OBS')
plt.plot([i for i in range(dlen)],mdataT,label='REAL')
"""
#plt.savefig('./temp_series.png',bbox_inches='tight')


#plot wind speed
sx = -0.3
ex = 7

plt.figure(figsize=(6,6))
plt.title('10 m windspeed observed vs REAL')
plt.xlabel('observed windspeed (m/s)')
plt.ylabel('simulated 10 m windspeed (m/s)')
plt.scatter(odataws,mdataws,s=siz,color=colr)
plt.xlim(sx,ex)
plt.ylim(sx,ex)
plt.plot([sx,ex],[sx,ex],'k')
#plt.show()
plt.savefig('./ws_valid.png',bbox_inches='tight')




#plot wind direction
sx = -0.5
ex = 360.5


plt.figure(figsize=(6,6))
plt.title('10 m wind direction observed vs REAL')
plt.xlabel('observed wind direction ($^\circ$)')
plt.ylabel('simulated 10 m wind direction ($^\circ$)')
plt.scatter(odatawd,mdatawd,s=siz,color=colr)
plt.xlim(sx,ex)
plt.ylim(sx,ex)
plt.xticks(np.arange(0,361,step=90))
plt.yticks(np.arange(0,361,step=90))
plt.plot([sx,ex],[sx,ex],'k')
#plt.show()
plt.savefig('./wd_valid.png',bbox_inches='tight')






