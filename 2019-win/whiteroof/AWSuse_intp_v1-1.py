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
dim = 28
sday = 15
trunc1 = 3
trunc2 = 0
dlen = 891-trunc2-trunc1 #change here!!


sdt = (sday -15)*24

#fil1 = 'geo_em.d03.nc'
fil1 = 'e2wrfout_d03_2018-07-14_12:00:00'
#fil4 = 'f7wrfout_d03_2018-07-14_12:00:00'
fil2 = 'AWS_stninfo_0715-0820_seoul_revised.csv'
fil3 = 'AWS_0715-0820_forValid_revised.csv'
metadata = pd.read_csv(diri1+diri2+fil2,sep=',',header=None)
stnnum = metadata[0]
mlat = np.array(metadata[1])
mlon = np.array(metadata[2])

ti1 = "Default"
ti2 = "white roof"
idx = pd.date_range("2018-07-15 00:00:00",periods=dlen,freq='H')

interpT = wi.intp_valid(fil1,mlat,mlon,"T2")[:,trunc1:dlen+trunc1] -273.15
interpU = wi.intp_valid(fil1,mlat,mlon,"U10")[:,trunc1:dlen+trunc1]
interpV = wi.intp_valid(fil1,mlat,mlon,"V10")[:,trunc1:dlen+trunc1]
#interpT2 = wi.intp_valid(fil4,mlat,mlon,"T2")[:,trunc1:dlen+trunc1] -273.15
#interpU2 = wi.intp_valid(fil4,mlat,mlon,"U10")[:,trunc1:dlen+trunc1]
#interpV2 = wi.intp_valid(fil4,mlat,mlon,"V10")[:,trunc1:dlen+trunc1]



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
gdata = b.gdata[:,sdt:dlen+sdt,:]

print(gdata.shape)
print(interpT.shape)
## gdata, interpT, interpU, interpV

interpws = (interpU**2.+interpV**2.)**0.5
interpwd = wind_direction(interpU*DIM,interpV*DIM)


mdataT = interpT.reshape(dim*dlen)
odataT = gdata[:,:,0].reshape(dim*dlen)
mdataws = interpws.reshape(dim*dlen)
odataws = gdata[:,:,2].reshape(dim*dlen)
mdatawd = interpwd.reshape(dim*dlen)
odatawd = gdata[:,:,1].reshape(dim*dlen)

modataT = np.mean(odataT,axis=0)
modataws = np.mean(odataws,axis=0)
modatawd = np.mean(mdatawd,axis=0)


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

fs = 12
ls = 10
a = 0.3

#plot T2
sx = 18
ex = 42

plt.figure(figsize=(4,4))
plt.xlim(sx,ex)
plt.ylim(sx,ex)
plt.title('Air temperature observed vs WRF',fontsize=fs)
plt.xlabel('observed temperature ($^\circ$C)',fontsize=fs)
plt.ylabel('simulated 2 m temperature ($^\circ$C)',fontsize=fs)
plt.scatter(odataT,mdataT,s=1,alpha=a)
plt.tick_params(axis = 'both',which='both',labelsize=ls)
plt.plot([sx,ex],[sx,ex],'k')
plt.tight_layout()
#plt.show()
plt.savefig("./aws_temp_valid.png")


#plot wind speed
sx = 0
ex = 12


plt.figure(figsize=(4,4))
plt.title('10 m windspeed observed vs WRF',fontsize=fs)
plt.xlabel('observed windspeed(m/s)',fontsize=fs)
plt.ylabel('simulated 10 m windspeed(m/s)',fontsize=fs)
plt.xlim(sx,ex)
plt.ylim(sx,ex)
plt.scatter(odataws,mdataws,s=1,alpha=a)
plt.tick_params(axis = 'both',which='both',labelsize=ls)
plt.plot([sx,ex],[sx,ex],'k')
plt.tight_layout()
#plt.show()
plt.savefig("./aws_ws_valid.png")


#plot wind direction


sx = -0.5
ex = 360.5

plt.figure(figsize=(4,4))
plt.title('10 m wind direction observed vs WRF',fontsize=fs)
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
plt.savefig("./aws_wd_valid.png")


#interpT & interpT2
#gdata[:,:,0]


#series for 28 stn
lw = 1.
ms = 2.
sy1 = 16
ey1 = 44

NAME = ['GangNam','SeoCho','GangDong','SongPa','GangSeo','YangCheon','DoBong','NoWon','DongDaemun','JungRyang','KMA','Mapo','Seodaemun','Gwangjin','SeongBuk','YongSan','EunPyeong','GeumCheon','HanGang','JungGu','SeongDong','Bukak-Mt','GuRo','GangBuk','NamHyun','Gwan-ak','YeongDeungPo','National Cemetery']

for i in range(dim):
	fig, ax = plt.subplots(ncols = 1, nrows = 1,sharex=True,figsize=(12,2))
	ax.plot_date(idx.to_pydatetime(),interpT[i,:],'bv-',markersize=ms,linewidth=lw,label=ti1)
#	ax.plot_date(idx.to_pydatetime(),interpT2[i,:],'rv-',markersize=ms,linewidth=lw,label=ti2)
	ax.plot_date(idx.to_pydatetime(),gdata[i,:,0],'ko',markersize=ms,linewidth=lw,label='OBS')
	ax.plot_date(idx.to_pydatetime(),[33 for i in range(dlen)],'k-')
	ax.xaxis.grid(True, color='k',which="major")
	ax.set_yticks([20,30,40])
	ax.yaxis.grid()
#	ax.set_ylabel('2 m temperature ($^\circ$C)')
	ax.set_ylabel(NAME[i])
#	ax.legend(loc='upper right')
	ax.set_ylim(sy1,ey1)
	ax.xaxis.set_major_locator(dates.WeekdayLocator(byweekday=(1),interval=1))
	ax.xaxis.set_major_formatter(dates.DateFormatter('%b %d'))
	ax.xaxis.set_minor_locator(dates.DayLocator())
	ax.set_xlabel('2018')
	plt.tight_layout()
	plt.savefig('./aws_valid_mean_series'+str(i+1)+'.png',bbox_inches='tight')
	plt.close(fig)











