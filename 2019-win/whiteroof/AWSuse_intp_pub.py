import sort_csv as sc
import wrf_intp as wi
import pandas as pd
import numpy as np
import matplotlib.pyplot as plt
import matplotlib.dates as dates
import datetime
from metpy.calc import wind_direction
from metpy.units import units

diri1 = '~/2019-win/whiteroof/'
diri2 = 'csv/'
dim = 28
sday = 15
trunc = 3
dlen = 891-trunc


sdt = (sday -15)*24

#fil1 = 'geo_em.d03.nc'
fil1 = 'e2wrfout_d03_2018-07-14_12:00:00'
fil4 = 'e7wrfout_d03_2018-07-14_12:00:00'
fil2 = 'AWS_stninfo_0715-0820_seoul_revised.csv'
fil3 = 'AWS_0715-0820_forValid_revised.csv'
metadata = pd.read_csv(diri1+diri2+fil2,sep=',',header=None)
stnnum = metadata[0]
mlat = np.array(metadata[1])
mlon = np.array(metadata[2])

ti1 = "CONV Case"
idx = pd.date_range("2018-07-15 00:00:00",periods=dlen,freq='H')


interpT = wi.intp_valid(fil1,mlat,mlon,"T2")[:,trunc:dlen+trunc] -273.15
interpU = wi.intp_valid(fil1,mlat,mlon,"U10")[:,trunc:dlen+trunc]
interpV = wi.intp_valid(fil1,mlat,mlon,"V10")[:,trunc:dlen+trunc]

DIM = units.meter/units.second

interpws = (interpU**2.+interpV**2.)**0.5
interpwd = wind_direction(interpU*DIM,interpV*DIM)


minterpT = np.mean(interpT,axis=0)
minterpws = np.mean(interpws,axis=0)
minterpwd = np.mean(interpwd,axis=0)

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
gdata = b.gdata[:,sdt:dlen+sdt,:]

print(gdata.shape)
print(interpT.shape)
## gdata, interpT, interpU, interpV



mdataT = minterpT.reshape(dlen)
mdataws = minterpws.reshape(dlen)
mdatawd = minterpwd.reshape(dlen)


odataT = np.mean(gdata[:,:,0],axis=0)
odataws = np.mean(gdata[:,:,2],axis=0)
odatawd = np.mean(gdata[:,:,1],axis=0)


n1 = 0
n2 = 0
VAR = 0.
ME = 0.
for i in range(dlen):
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


n1 = 0
n2 = 0
VAR = 0.
ME = 0.
for i in range(dlen):
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

fs = 14
ls = 14
a = 0.5

#plot T2
sx = 18
ex = 42

plt.figure(figsize=(4,4))
plt.xlim(sx,ex)
plt.ylim(sx,ex)
#plt.title('Mean Air temperature observed vs WRF',fontsize=fs)
plt.xlabel('observed temperature ($^\circ$C)',fontsize=fs)
plt.ylabel('simulated 2 m temperature ($^\circ$C)',fontsize=fs)
plt.scatter(odataT,mdataT,s=1,alpha=a)
plt.tick_params(axis = 'both',which='both',labelsize=ls)
plt.plot([sx,ex],[sx,ex],'k')
plt.tight_layout()
#plt.show()
plt.savefig("./aws_meantemp_valid_pub.png")


#plot wind speed
sx = 0
ex = 7


plt.figure(figsize=(4,4))
#plt.title('Mean 10 m windspeed observed vs WRF',fontsize=fs)
plt.xlabel('observed windspeed (m/s)',fontsize=fs)
plt.ylabel('simulated 10 m windspeed (m/s)',fontsize=fs)
plt.xlim(sx,ex)
plt.ylim(sx,ex)
plt.scatter(odataws,mdataws,s=1,alpha=a)
plt.tick_params(axis = 'both',which='both',labelsize=ls)
plt.xticks(np.arange(sx,ex+1,1))
plt.yticks(np.arange(sx,ex+1,1))
plt.plot([sx,ex],[sx,ex],'k')
plt.tight_layout()
#plt.show()
plt.savefig("./aws_meanws_valid_pub.png")


#plot wind direction


sx = -0.5
ex = 360.5

plt.figure(figsize=(4,4))
#plt.title('Mean 10 m wind direction observed vs WRF',fontsize=fs)
plt.xlabel('observed wind direction',fontsize=fs)
plt.ylabel('simulated 10 m wind direction',fontsize=fs)
plt.xlim(sx,ex)
plt.ylim(sx,ex)
plt.xticks(np.arange(0,361,step=90),[" ","E","S","W","N"])
plt.yticks(np.arange(0,361,step=90),[" ","E","S","W","N"])
plt.scatter(odatawd,mdatawd,s=1,alpha=a)
plt.tick_params(axis = 'both',which='both',labelsize=ls+2)
plt.grid(which='major',axis='both',color='k')
plt.plot([sx,ex],[sx,ex],'k')
plt.tight_layout()
#plt.show()
plt.savefig("./aws_meanwd_valid_pub.png")

lw = 1.
ms = 2.
sy1 = 18
ey1 = 42
sy2 = -0.2
ey2 = 7
sy3 = -6
ey3 = 366

fsp = 12
fsp1 = 14
fsp2 = 13

fig, ax = plt.subplots(ncols = 1, nrows = 2,sharex=True,figsize=(12,5))
ax[0].plot_date(idx.to_pydatetime(),mdataT,'r-',markersize=ms,linewidth=lw,label=ti1)
ax[0].plot_date(idx.to_pydatetime(),odataT,'ko',markersize=ms,linewidth=lw,label='OBS')
ax[0].plot_date(idx.to_pydatetime(),[33 for i in range(dlen)],'k-')
ax[0].xaxis.grid(True, color='k',which="major")
ax[0].yaxis.grid()
ax[0].set_ylabel('2 m temperature ($^\circ$C)',fontsize=fsp)
ax[0].legend(loc='upper right',fontsize=fsp)
ax[0].set_ylim(sy1,ey1)
ax[0].tick_params(axis="y", labelsize=fsp2)
ax[1].plot_date(idx.to_pydatetime(),mdataws,'r-',markersize=ms,linewidth=lw,label=ti1)
ax[1].plot_date(idx.to_pydatetime(),odataws,'ko',markersize=ms,linewidth=lw,label='OBS')
ax[1].xaxis.grid(True, color='k',which="major")
ax[1].yaxis.grid()
ax[1].set_ylabel('10 m windspeed(m/s)',fontsize=fsp)
ax[1].set_ylim(sy2,ey2)
ax[1].xaxis.set_major_locator(dates.WeekdayLocator(byweekday=(1),interval=1))
ax[1].xaxis.set_major_formatter(dates.DateFormatter('%b %d'))
ax[1].tick_params(axis="x", labelsize=fsp1)
ax[1].tick_params(axis="y", labelsize=fsp2)
ax[1].xaxis.set_minor_locator(dates.DayLocator())
ax[1].set_xlabel('2018',fontsize=fsp1)
ax[1].set_xlim([datetime.datetime(2018,7,14,19,0,0),datetime.datetime(2018,8,21,5,0,0)])
plt.tight_layout()
plt.savefig('./aws_valid_mean_series_pub.png',bbox_inches='tight')
#plt.show()





