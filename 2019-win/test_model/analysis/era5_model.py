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
from netCDF4 import Dataset
from wrf import getvar, ALL_TIMES

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


diri1 = '~/2019-win/test_model/'
diri2 = 'csv/'
dim = 28
sday = 15
trunc = 3
#dlen = 51-trunc
dlen = 891-trunc
#trunc = 3
#sday = 26
#dlen = 24

fil1 = 'diff_era_model.nc'

nf = Dataset(fil1)

etpbl = nf['etpbl'][:]
etlh = nf['etlh'][:]
etsh = nf['etsh'][:]
mtpbl = nf['mtpbl'][:]
mtlh = nf['mtlh'][:]
mtsh = nf['mtsh'][:]


sdt = (sday -15)*24
ti1 = "CONV Case"
idx = pd.date_range("2018-07-15 00:00:00",periods=dlen,freq='H')

dlen = 888

n1 = 0
n2 = 0
VAR = 0.
ME = 0.
for i in range(dlen):
	if pd.notnull(etpbl[i]):
		diff = etpbl[i] - mtpbl[i]
		VAR += diff**2
		ME += diff
		n1 += 1
RMSE = (VAR/float(n1))**0.5
ME = ME/float(n1)

print("RMSE of PBL = {}".format(RMSE))
print("Mean error of PBL = {}".format(ME))



n1 = 0
n2 = 0
VAR = 0.
ME = 0.
for i in range(dlen):
    if pd.notnull(etsh[i]):
        diff = mtsh[i] - etsh[i]
        VAR += diff**2
        ME += diff
        n1 += 1

RMSE = (VAR/float(n1))**0.5
ME = ME/float(n1)

print("RMSE of HFX = {}".format(RMSE))
print("Mean error of HFX = {}".format(ME))




n1 = 0
n2 = 0
VAR = 0.
ME = 0.
for i in range(dlen):
    if pd.notnull(etlh[i]):
        diff = mtlh[i] - etlh[i]
        VAR += diff**2
        ME += diff
        n1 += 1

RMSE = (VAR/float(n1))**0.5
ME = ME/float(n1)

print(n1)

print("RMSE of LH = {}".format(RMSE))
print("Mean error of LH = {}".format(ME))


fs = 14
ls = 14
a = 1.0

#sx = 8
#ex = 24


fig, ax = plt.subplots(ncols = 1, nrows = 1, figsize=(4,4))
#plt.title('Mean 10 m windspeed observed vs WRF',fontsize=fs)
ax.set_xlabel('observed PBLH (m)',fontsize=fs)
ax.set_ylabel('simulated PBLH (m)',fontsize=fs)
#ax.set_xlim(sx,ex)
#ax.set_ylim(sx,ex)
ax.scatter(etpbl,mtpbl,s=1,color='k',alpha=a)
ax.tick_params(axis = 'both',which='both',labelsize=ls)
#ax.xticks(np.arange(sx,ex+1,1))
#plt.yticks(np.arange(sx,ex+1,1))
#ax.plot([sx,ex],[sx,ex],'k')
ax.tick_params(which='major',width=1.2,length=7)
ax.tick_params(which='minor',width=1.0,length=3)
#ax.yaxis.set_minor_locator(AutoMinorLocator())
#ax.xaxis.set_minor_locator(AutoMinorLocator())
#ax.xaxis.set_major_locator(MultipleLocator(5))
#ax.yaxis.set_major_locator(MultipleLocator(5))

ax.set_aspect(1)

plt.tight_layout()
plt.savefig("../picture/aws_meanPBL_valid_pub.png")
plt.show()



fs = 14
ls = 14
a = 1.0

#sx = 8
#ex = 24


fig, ax = plt.subplots(ncols = 1, nrows = 1, figsize=(4,4))
#plt.title('Mean 10 m windspeed observed vs WRF',fontsize=fs)
ax.set_xlabel('observed HFX (W m-2)',fontsize=fs)
ax.set_ylabel('simulated HFX (W m-2)',fontsize=fs)
#ax.set_xlim(sx,ex)
#ax.set_ylim(sx,ex)
ax.scatter(etsh,mtsh,s=1,color='k',alpha=a)
ax.tick_params(axis = 'both',which='both',labelsize=ls)
#ax.xticks(np.arange(sx,ex+1,1))
#plt.yticks(np.arange(sx,ex+1,1))
#ax.plot([sx,ex],[sx,ex],'k')
ax.tick_params(which='major',width=1.2,length=7)
ax.tick_params(which='minor',width=1.0,length=3)
#ax.yaxis.set_minor_locator(AutoMinorLocator())
#ax.xaxis.set_minor_locator(AutoMinorLocator())
#ax.xaxis.set_major_locator(MultipleLocator(5))
#ax.yaxis.set_major_locator(MultipleLocator(5))

ax.set_aspect(1)

plt.tight_layout()
plt.savefig("../picture/aws_meanHFX_valid_pub.png")
plt.show()



fs = 14
ls = 14
a = 1.0

#sx = 8
#ex = 24


fig, ax = plt.subplots(ncols = 1, nrows = 1, figsize=(4,4))
#plt.title('Mean 10 m windspeed observed vs WRF',fontsize=fs)
ax.set_xlabel('observed LH (W m-2)',fontsize=fs)
ax.set_ylabel('simulated LH (W m-2)',fontsize=fs)
#ax.set_xlim(sx,ex)
#ax.set_ylim(sx,ex)
ax.scatter(etlh,mtlh,s=1,color='k',alpha=a)
ax.tick_params(axis = 'both',which='both',labelsize=ls)
#ax.xticks(np.arange(sx,ex+1,1))
#plt.yticks(np.arange(sx,ex+1,1))
#ax.plot([sx,ex],[sx,ex],'k')
ax.tick_params(which='major',width=1.2,length=7)
ax.tick_params(which='minor',width=1.0,length=3)
#ax.yaxis.set_minor_locator(AutoMinorLocator())
#ax.xaxis.set_minor_locator(AutoMinorLocator())
#ax.xaxis.set_major_locator(MultipleLocator(5))
#ax.yaxis.set_major_locator(MultipleLocator(5))

ax.set_aspect(1)

plt.tight_layout()
plt.savefig("../picture/aws_meanLH_valid_pub.png")
plt.show()



lw = 1.
ms = 2.
sy1 = 18
ey1 = 42
sy2 = 0
ey2 = 7
sy3 = -6
ey3 = 366

fsp = 14
fsp1 = 17
fsp11 = 14
fsp2 = 13

#fig, ax = plt.subplots(ncols = 1, nrows = 2,sharex=True,figsize=(14,8))
fig, ax = plt.subplots(ncols = 1, nrows = 3,figsize=(14,12))
ax[0].plot_date(idx.to_pydatetime(),mtpbl,'r-',markersize=ms,linewidth=lw,label=ti1)
ax[0].plot_date(idx.to_pydatetime(),etpbl,'ko',markersize=ms,linewidth=lw,label='ERA5')
#ax[0].plot_date(idx.to_pydatetime(),[33 for i in range(dlen)],'k-')
#ax[0].xaxis.grid(True, color='k',which="major")
#ax[0].yaxis.grid()
ax[0].set_ylabel(u'PBLH (m)',fontsize=fsp)
ax[0].legend(loc='upper left',frameon=False,fontsize=fsp)
#ax[0].set_ylim(sy1,ey1)
ax[0].tick_params(axis="y", labelsize=fsp2)
ax[0].xaxis.set_major_locator(dates.WeekdayLocator(byweekday=(1),interval=1))
ax[0].xaxis.set_major_formatter(dates.DateFormatter('%d %b'))
ax[0].tick_params(axis="x", labelsize=fsp11)
ax[0].set_xlim([datetime.datetime(2018,7,15,0,0,0),datetime.datetime(2018,8,21,0,0,0)])
ax[0].xaxis.set_minor_locator(dates.DayLocator())
ax[0].set_xlabel('2018',fontsize=fsp1)




ax[1].plot_date(idx.to_pydatetime(),mtsh,'r-',markersize=ms,linewidth=lw,label=ti1)
ax[1].plot_date(idx.to_pydatetime(),etsh,'ko',markersize=ms,linewidth=lw,label='ERA5')
#ax[1].xaxis.grid(True, color='k',which="major")
#ax[1].yaxis.grid()
ax[1].set_ylabel('sensible heat flux (W m$^{-2}$)',fontsize=fsp)
#ax[1].set_ylim(sy2,ey2)
ax[1].xaxis.set_major_locator(dates.WeekdayLocator(byweekday=(1),interval=1))
ax[1].xaxis.set_major_formatter(dates.DateFormatter('%d %b'))
ax[1].tick_params(axis="x", labelsize=fsp11)
ax[1].tick_params(axis="y", labelsize=fsp2)
ax[1].xaxis.set_minor_locator(dates.DayLocator())
ax[1].set_xlabel('2018',fontsize=fsp1)
ax[1].set_xlim([datetime.datetime(2018,7,15,0,0,0),datetime.datetime(2018,8,21,0,0,0)])


ax[2].plot_date(idx.to_pydatetime(),mtlh,'r-',markersize=ms,linewidth=lw,label=ti1)
ax[2].plot_date(idx.to_pydatetime(),etlh,'ko',markersize=ms,linewidth=lw,label='ERA5')
#ax[1].xaxis.grid(True, color='k',which="major")
#ax[1].yaxis.grid()
ax[2].set_ylabel('latent heat flux (W m$^{-2}$)',fontsize=fsp)
#ax[1].set_ylim(sy2,ey2)
ax[2].xaxis.set_major_locator(dates.WeekdayLocator(byweekday=(1),interval=1))
ax[2].xaxis.set_major_formatter(dates.DateFormatter('%d %b'))
ax[2].tick_params(axis="x", labelsize=fsp11)
ax[2].tick_params(axis="y", labelsize=fsp2)
ax[2].xaxis.set_minor_locator(dates.DayLocator())
ax[2].set_xlabel('2018',fontsize=fsp1)
ax[2].set_xlim([datetime.datetime(2018,7,15,0,0,0),datetime.datetime(2018,8,21,0,0,0)])





ax[0].tick_params(which='major',width=1.2,length=7)
ax[0].tick_params(which='minor',width=1.0,length=3)
ax[1].tick_params(which='major',width=1.2,length=7)
ax[1].tick_params(which='minor',width=1.0,length=3)
ax[0].yaxis.set_minor_locator(AutoMinorLocator())
ax[1].yaxis.set_minor_locator(AutoMinorLocator())




fig.text(0.125,0.89,'(a)',fontsize=fsp11+5)
fig.text(0.125,0.61,'(b)',fontsize=fsp11+5)
fig.text(0.125,0.33,'(c)',fontsize=fsp11+5)
plt.subplots_adjust(hspace=0.30)
#plt.tight_layout()
plt.savefig('../picture/aws_valid_mean_series.png',bbox_inches='tight')

plt.show()




