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
#sday = 15
#trunc = 3
#dlen = 891-trunc

trunc = 3
sday = 3
dlen = 24


sdt = (sday -3)*24

#fil1 = 'geo_em.d03.nc'
fil1 = 'yswrfout_d03_2016-08-02_12:00:00'
fil4 = 'mynnwrfout_d03_2016-08-02_12:00:00'
fil5 = 'qnsewrfout_d03_2016-08-02_12:00:00'
fil2 = 'AWS_stninfo_Seoul_2016Revised.csv'
fil3 = 'AWS_0803-0809_forValid_revised.csv'
metadata = pd.read_csv(diri1+diri2+fil2,sep=',',header=None)
stnnum = metadata[0]
mlat = np.array(metadata[1])
mlon = np.array(metadata[2])

ti1 = "YSU"
ti2 = "MYNN"
ti3 = "QNSE"
idx = pd.date_range("2016-08-03 00:00:00",periods=dlen,freq='H')


interpT = wi.intp_valid(fil1,mlat,mlon,"T2")[:,sdt+trunc:sdt+dlen+trunc] -273.15
interpU = wi.intp_valid(fil1,mlat,mlon,"U10")[:,sdt+trunc:sdt+dlen+trunc]
interpV = wi.intp_valid(fil1,mlat,mlon,"V10")[:,sdt+trunc:sdt+dlen+trunc]
interpT2 = wi.intp_valid(fil4,mlat,mlon,"T2")[:,sdt+trunc:sdt+dlen+trunc] -273.15
interpU2 = wi.intp_valid(fil4,mlat,mlon,"U10")[:,sdt+trunc:sdt+dlen+trunc]
interpV2 = wi.intp_valid(fil4,mlat,mlon,"V10")[:,sdt+trunc:sdt+dlen+trunc]
interpT3 = wi.intp_valid(fil5,mlat,mlon,"T2")[:,sdt+trunc:sdt+dlen+trunc] -273.15
interpU3 = wi.intp_valid(fil5,mlat,mlon,"U10")[:,sdt+trunc:sdt+dlen+trunc]
interpV3 = wi.intp_valid(fil5,mlat,mlon,"V10")[:,sdt+trunc:sdt+dlen+trunc]


DIM = units.meter/units.second

interpws = (interpU**2.+interpV**2.)**0.5
interpws2 = (interpU2**2.+interpV2**2.)**0.5
interpws3 = (interpU3**2.+interpV3**2.)**0.5

interpwd = wind_direction(interpU*DIM,interpV*DIM)
interpwd2 = wind_direction(interpU2*DIM,interpV2*DIM)
interpwd3 = wind_direction(interpU3*DIM,interpV3*DIM)



#print(interpT.shape)

vdata = pd.read_csv(diri1+diri2+fil3,sep=',',header=None)
stndata = vdata[0]
date = vdata[1]
rdata = vdata.drop([0,1],axis=1)
rd = rdata.values
sd = stndata.values
dd = date.values
b = sc.sep_csv(sd,rd,dd)


DATE = sc.yymmddhh(2016,8,3,2016,8,9)
b.date_csv(DATE)
gdata = b.gdata[:,sdt:dlen+sdt,:]

print(gdata.shape)
print(interpT.shape)
## gdata, interpT, interpU, interpV


d1 = len(gdata[:,0,0])
d2 = len(gdata[0,:,0])

odataT, odataws, odatawd = np.zeros(d2), np.zeros(d2), np.zeros(d2)
mdataT, mdataws, mdatawd = np.zeros(d2), np.zeros(d2), np.zeros(d2)
mdataT2, mdataws2, mdatawd2 = np.zeros(d2), np.zeros(d2), np.zeros(d2)
mdataT3, mdataws3, mdatawd3 = np.zeros(d2), np.zeros(d2), np.zeros(d2)


for j in range(d2):
	n = 0
	for i in range(d1):
		if not np.isnan(gdata[i,j,0]):
			odataT[j] += gdata[i,j,0]
			mdataT[j] += interpT[i,j]
			mdataT2[j] += interpT2[i,j]
			mdataT3[j] += interpT3[i,j]
			n += 1
	odataT[j] = odataT[j]/float(n)
	mdataT[j] = mdataT[j]/float(n)
	mdataT2[j] = mdataT2[j]/float(n)
	mdataT3[j] = mdataT3[j]/float(n)

for j in range(d2):
	n = 0
	for i in range(d1):
		if not np.isnan(gdata[i,j,2]):
			odataws[j] += gdata[i,j,2]
			mdataws[j] += interpws[i,j]
			mdataws2[j] += interpws2[i,j]
			mdataws3[j] += interpws3[i,j]
			n += 1
	odataws[j] = odataws[j]/float(n)
	mdataws[j] = mdataws[j]/float(n)
	mdataws2[j] = mdataws2[j]/float(n)
	mdataws3[j] = mdataws3[j]/float(n)

for j in range(d2):
	n = 0
	for i in range(d1):
		if not np.isnan(gdata[i,j,1]):
			odatawd[j] += gdata[i,j,1]
			mdatawd[j] += interpwd[i,j]

			n += 1
	odatawd[j] = odatawd[j]/float(n)
	mdatawd[j] = mdatawd[j]/float(n)


#odataT = np.mean(gdata[:,:,0],axis=0) #stn X time X var
#odataws = np.mean(gdata[:,:,2],axis=0)
#odatawd = np.mean(gdata[:,:,1],axis=0)



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
        if diff<=1. and diff>=-1:
            n2 += 1

RMSE = (VAR/float(n1))
ME = ME/float(n1)
HRT = float(n2)/float(n1) *100

print("Hit rate of WS = {}".format(HRT))
print("RMSE of wind speed = {}".format(RMSE))
print("Mean error of wind speed = {}".format(ME))

fs = 14
ls = 14
a = 0.5

fsp1 = 14
#plot T2
sx = 18
ex = 42

fig, ax = plt.subplots(ncols = 2, nrows = 1, figsize=(9,4))
#plt.title('Mean 10 m windspeed observed vs WRF',fontsize=fs)
ax[0].set_xlabel('observed temperature (\u00B0C)',fontsize=fs)
ax[0].set_ylabel('simulated 2 m temperature (\u00B0C)',fontsize=fs)
ax[0].set_xlim(sx,ex)
ax[0].set_ylim(sx,ex)
ax[0].scatter(odataT,mdataT,s=1,alpha=a)
ax[0].tick_params(axis = 'both',which='both',labelsize=ls)
#ax.xticks(np.arange(sx,ex+1,1))
#plt.yticks(np.arange(sx,ex+1,1))
ax[0].plot([sx,ex],[sx,ex],'k')
ax[0].tick_params(which='major',width=1.2,length=7)
ax[0].tick_params(which='minor',width=1.0,length=3)
ax[0].yaxis.set_minor_locator(AutoMinorLocator())
ax[0].xaxis.set_minor_locator(AutoMinorLocator())
ax[0].set_aspect(1)

#plt.tight_layout()
#plt.show()
#plt.savefig("./aws_meantemp_valid_pub.png")


#plot wind speed
sx = 0
ex = 7


#fig, ax = plt.subplots(ncols = 1, nrows = 1, figsize=(4,4))
#plt.title('Mean 10 m windspeed observed vs WRF',fontsize=fs)
ax[1].set_xlabel('observed windspeed (m s$^{-1}$)',fontsize=fs)
ax[1].set_ylabel('simulated 10 m windspeed (m s$^{-1}$)',fontsize=fs)
ax[1].set_xlim(sx,ex)
ax[1].set_ylim(sx,ex)
ax[1].scatter(odataws,mdataws,s=1,alpha=a)
ax[1].tick_params(axis = 'both',which='both',labelsize=ls)
#ax.xticks(np.arange(sx,ex+1,1))
#plt.yticks(np.arange(sx,ex+1,1))
ax[1].plot([sx,ex],[sx,ex],'k')
ax[1].tick_params(which='major',width=1.2,length=7)
ax[1].tick_params(which='minor',width=1.0,length=3)
ax[1].yaxis.set_minor_locator(AutoMinorLocator())
ax[1].xaxis.set_minor_locator(AutoMinorLocator())
ax[1].yaxis.set_major_locator(MultipleLocator(2))
ax[1].set_aspect(1)
fig.text(0.155,0.905,'(a)',fontsize=fsp1+5)
fig.text(0.585,0.905,'(b)',fontsize=fsp1+5)
plt.subplots_adjust(left=0.15,bottom=0.18,top=0.88,wspace=0.34)

#plt.tight_layout()
plt.savefig("./aws_meantw_valid_pub.png")
plt.show()


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
#plt.tight_layout()
#plt.show()
plt.savefig("./aws_meanwd_valid_pub.png")

lw = 1.
ms = 2.
sy1 = 23
ey1 = 38
sy2 = 0
ey2 = 4
sy3 = -6
ey3 = 366

fsp = 14
fsp1 = 14
fsp2 = 13

fig, ax = plt.subplots(ncols = 1, nrows = 2,sharex=True,figsize=(4,8))
ax[0].plot_date(idx.to_pydatetime(),mdataT,'r-',markersize=ms,linewidth=lw,label=ti1)
ax[0].plot_date(idx.to_pydatetime(),mdataT2,'b-',markersize=ms,linewidth=lw,label=ti2)
ax[0].plot_date(idx.to_pydatetime(),mdataT3,'g-',markersize=ms,linewidth=lw,label=ti3)
ax[0].plot_date(idx.to_pydatetime(),odataT,'ko',markersize=ms,linewidth=lw,label='OBS')
#ax[0].plot_date(idx.to_pydatetime(),[33 for i in range(dlen)],'k-')
#ax[0].xaxis.grid(True, color='k',which="major")
#ax[0].yaxis.grid()
ax[0].set_ylabel(u'2 m temperature (\u00B0C)',fontsize=fsp)
ax[0].legend(loc='upper left',frameon=False,fontsize=fsp)
ax[0].set_ylim(sy1,ey1)
ax[0].tick_params(axis="y", labelsize=fsp2)
ax[0].xaxis.set_major_locator(dates.HourLocator(interval=3))
ax[0].xaxis.set_major_formatter(dates.DateFormatter('%H'))
ax[1].plot_date(idx.to_pydatetime(),mdataws,'r-',markersize=ms,linewidth=lw,label=ti1)
ax[1].plot_date(idx.to_pydatetime(),mdataws2,'b-',markersize=ms,linewidth=lw,label=ti2)
ax[1].plot_date(idx.to_pydatetime(),mdataws3,'g-',markersize=ms,linewidth=lw,label=ti3)
ax[1].plot_date(idx.to_pydatetime(),odataws,'ko',markersize=ms,linewidth=lw,label='OBS')
#ax[1].xaxis.grid(True, color='k',which="major")
#ax[1].yaxis.grid()
ax[1].set_ylabel('10 m windspeed (m s$^{-1}$)',fontsize=fsp)
ax[1].set_ylim(sy2,ey2)
#ax[1].xaxis.set_major_locator(dates.WeekdayLocator(byweekday=(1),interval=1))
ax[1].xaxis.set_major_locator(dates.HourLocator(interval=3))
ax[1].xaxis.set_major_formatter(dates.DateFormatter('%H'))
ax[1].tick_params(axis="x", labelsize=fsp1)
ax[1].tick_params(axis="y", labelsize=fsp2)
ax[1].xaxis.set_minor_locator(dates.HourLocator())
#ax[1].set_xlabel('2016',fontsize=fsp1)
ax[1].set_xlim([datetime.datetime(2016,8,3,0,0,0),datetime.datetime(2016,8,4,0,0,0)])
ax[0].tick_params(which='major',width=1.2,length=7)
ax[0].tick_params(which='minor',width=1.0,length=3)
ax[1].tick_params(which='major',width=1.2,length=7)
ax[1].tick_params(which='minor',width=1.0,length=3)
ax[0].yaxis.set_minor_locator(AutoMinorLocator())
ax[1].yaxis.set_minor_locator(AutoMinorLocator())

fig.text(0.125,0.9,'(a)',fontsize=fsp1+5)
fig.text(0.125,0.46,'(b)',fontsize=fsp1+5)
plt.subplots_adjust(hspace=0.30)
#plt.tight_layout()
plt.savefig('./aws_valid_mean_series_pub.png',bbox_inches='tight')
#plt.show()





