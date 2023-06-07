import pandas as pd
import numpy as np
import matplotlib.pyplot as plt
import matplotlib.dates as dates
import Ngl
import sys
import datetime
from matplotlib import font_manager as fm, rcParams
from matplotlib.ticker import AutoMinorLocator, MultipleLocator
from matplotlib import rc
from metpy.calc import wind_direction
from netCDF4 import Dataset
from metpy.units import units
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



diri1 = '~/2019-win/whiteroof/'
diri2 = 'csv/'
dim = 1
sday = 15
#dlen = 737
trunc = 3
dlen = 891-trunc

#sday = 21
#dlen = 24*7

sdt = (sday - 15)*24 # for ASOS data

fil1 = 'e2wrfout_d03_2018-07-14_12:00:00'
fil2 = 'e7wrfout_d03_2018-07-14_12:00:00'
fil3 = 'bon_seoul.nc'

ti1 = "conventional-roof case"
ti2 = "cool-roof case"
idx = pd.date_range("2018-07-15 00:00:00",periods=dlen,freq='H')
print(idx)

file1 = Dataset(fil1)
file2 = Dataset(fil2)
file3 = Dataset(fil3)

xlat = getvar(file1,"lat")
xlon = getvar(file1,"lon")
lu = getvar(file1,"LU_INDEX")
T1 = getvar(file1,"T2",timeidx=ALL_TIMES)[trunc:trunc+dlen,:,:] -273.15
T2 = getvar(file2,"T2",timeidx=ALL_TIMES)[trunc:trunc+dlen,:,:] -273.15
BON = file3['BON']

#print(BON)

d1 = len(xlat[:,0])
d2 = len(xlat[0,:])
dt = len(T2[:,0,0])
#print(d1)
#print(d2)


mut1 = np.zeros(dt)
mut2 = np.zeros(dt)
n = 0
for i in range(d1):
	for j in range(d2):
		if (lu[i,j] == 13 or lu[i,j]>=31) and BON[i,j] == 1:
			mut1 += T1[:,i,j]
			mut2 += T2[:,i,j]
			n += 1
mut1 = mut1/float(n)
mut2 = mut2/float(n)

met1 = np.mean(T1,axis=1)
met2 = np.mean(T2,axis=1)
mt1 = np.mean(met1,axis=1)
mt2 = np.mean(met2,axis=1)

diff = list(mut2-mut1)
#print(diff)

mmu = min(mut2-mut1)
aaa = diff.index(mmu)
print(aaa)
print(idx[aaa])




#scatter option
siz = 3
colr = 'b'

#plot T2
sy1 = 17.9
ey1 = 40
sy2 = -1.8
ey2 = 1.8

lw = 1.5
ms = 2.

fsp = 14
fsp1 = 14
fsp2 = 13


#fig, ax = plt.subplots(ncols = 1, nrows = 2,sharex=True,figsize=(14,8))
fig, ax = plt.subplots(ncols = 1, nrows = 2,figsize=(14,8))
ax[0].set_ylim(sy1,ey1)
ax[0].plot_date(idx.to_pydatetime(),mut1,'r-',markersize=ms,linewidth=lw,label=ti1)
ax[0].plot_date(idx.to_pydatetime(),mut2,'b-',markersize=ms,linewidth=lw,label=ti2)


#ax[0].plot_date(idx.to_pydatetime(),[33 for i in range(dlen)],'k-')
#ax[0].xaxis.grid(True, which="minor",linestyle='--')
#ax[0].xaxis.grid(True, color='k',which="major")
#ax[0].yaxis.grid()
ax[0].set_ylabel('2-m temperature (\u00B0C)',fontsize=fsp)
#ax[0].legend(loc='lower center',frameon=False,fontsize=fsp)
ax[0].tick_params(axis="y", labelsize=fsp2)
ax[0].set_ylim(sy1,ey1)
ax[0].xaxis.set_major_locator(dates.WeekdayLocator(byweekday=(1),interval=1))
ax[0].xaxis.set_major_formatter(dates.DateFormatter('%d %b'))
ax[0].set_xlabel('2018',fontsize=fsp1+3)
ax[0].set_xlim([datetime.datetime(2018,7,15,0,0,0),datetime.datetime(2018,8,21,0,0,0)])
ax[0].tick_params(axis="x", labelsize=fsp1)
ax[0].xaxis.set_minor_locator(dates.DayLocator())

ax[1].set_ylim(sy2,ey2)
ax[1].plot_date(idx.to_pydatetime(),mut2-mut1,'k-',markersize=ms,linewidth=lw)
#ax[1].xaxis.grid(True,color="k",which="major")
ax[1].xaxis.set_major_locator(dates.WeekdayLocator(byweekday=(1),interval=1))
ax[1].plot_date(idx.to_pydatetime(),[0 for i in range(dlen)],'k-')
ax[1].set_ylabel('difference (\u00B0C)',fontsize=fsp)
ax[1].tick_params(axis="x", labelsize=fsp1)
ax[1].tick_params(axis="y", labelsize=fsp2)
ax[1].set_xlim([datetime.datetime(2018,7,15,0,0,0),datetime.datetime(2018,8,21,0,0,0)])
#ax[1].xaxis.set_major_locator(dates.DayLocator())
ax[0].tick_params(which='major',width=1.2,length=7)
ax[0].tick_params(which='minor',width=1.0,length=3)
ax[1].tick_params(which='major',width=1.2,length=7)
ax[1].tick_params(which='minor',width=1.0,length=3)
ax[0].yaxis.set_minor_locator(AutoMinorLocator())
ax[1].yaxis.set_minor_locator(AutoMinorLocator())

ax[1].xaxis.set_major_formatter(dates.DateFormatter('%d %b'))
ax[1].xaxis.set_minor_locator(dates.DayLocator())
#ax[1].xaxis.grid(True, which="minor",linestyle='--')
ax[1].set_xlabel('2018',fontsize=fsp1+3)

handles, labels = ax[0].get_legend_handles_labels()
labels = [ti1,ti2]
dict_labels_handles = dict(zip(labels,handles))

handles = [dict_labels_handles[l] for l in labels]
ax[0].legend(handles,labels,loc='lower center',frameon=False,fontsize=fsp)


fig.text(0.125,0.9,'(a)',fontsize=fsp1+5)
fig.text(0.125,0.46,'(b)',fontsize=fsp1+5)
plt.subplots_adjust(hspace=0.30)

#plt.tight_layout()
plt.savefig('./compare_alb_pub.png',bbox_inches='tight')
#plt.show()







