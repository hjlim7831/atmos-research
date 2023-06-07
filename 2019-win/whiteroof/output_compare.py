import pandas as pd
import numpy as np
import matplotlib.pyplot as plt
import matplotlib.dates as dates
import sys
from metpy.calc import wind_direction
from netCDF4 import Dataset
from metpy.units import units
from wrf import getvar, ALL_TIMES

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

ti1 = "alb 0.2"
ti2 = "alb 0.7"
idx = pd.date_range("2018-07-15 00:00:00",periods=dlen,freq='H')

file1 = Dataset(fil1)
file2 = Dataset(fil2)

xlat = getvar(file1,"lat")
xlon = getvar(file1,"lon")
lu = getvar(file1,"LU_INDEX")
T1 = getvar(file1,"T2",timeidx=ALL_TIMES)[trunc:trunc+dlen,:,:] -273.15
T2 = getvar(file2,"T2",timeidx=ALL_TIMES)[trunc:trunc+dlen,:,:] -273.15

d1 = len(xlat[:,0])
d2 = len(xlat[0,:])
dt = len(T2[:,0,0])
print(d1)
print(d2)

mut1 = np.zeros(dt)
mut2 = np.zeros(dt)
n = 0
for i in range(d1):
	for j in range(d2):
		if lu[i,j] == 13 or lu[i,j]>=31:
			mut1 += T1[:,i,j]
			mut2 += T2[:,i,j]
			n += 1
mut1 = mut1/float(n)
mut2 = mut2/float(n)

met1 = np.mean(T1,axis=1)
met2 = np.mean(T2,axis=1)
mt1 = np.mean(met1,axis=1)
mt2 = np.mean(met2,axis=1)





#scatter option
siz = 3
colr = 'b'

#plot T2
sy1 = 19
ey1 = 37
sy2 = 19
ey2 = 37

lw = 1.
ms = 2.

fig, ax = plt.subplots(ncols = 1, nrows = 3,sharex=True,figsize=(12,7))
ax[0].plot_date(idx.to_pydatetime(),mt1,'bv-',markersize=ms,linewidth=lw,label=ti1)
ax[0].plot_date(idx.to_pydatetime(),mt2,'rv-',markersize=ms,linewidth=lw,label=ti2)
#ax[0].plot_date(idx.to_pydatetime(),[33 for i in range(dlen)],'k-')
#ax[0].xaxis.grid(True, which="minor",linestyle='--')
ax[0].xaxis.grid(True, color='k',which="major")
ax[0].yaxis.grid()
ax[0].set_ylabel('T2 average for whole area ($^\circ$C)')
ax[0].legend(loc='upper right')

ax[1].set_ylim(sy1,ey1)
ax[1].plot_date(idx.to_pydatetime(),mut1,'bv-',markersize=ms,linewidth=lw,label=ti1)
ax[1].plot_date(idx.to_pydatetime(),mut2,'rv-',markersize=ms,linewidth=lw,label=ti2)
#ax[1].plot_date(idx.to_pydatetime(),[33 for i in range(dlen)],'k-')
#ax[1].xaxis.grid(True, which="minor",linestyle='--')
ax[1].xaxis.grid(True, color='k',which="major")
ax[1].yaxis.grid()
ax[1].set_ylabel('T2 average for urban ($^\circ$C)')
ax[1].legend(loc='upper right')
ax[1].set_ylim(sy2,ey2)


ax[2].plot_date(idx.to_pydatetime(),mt2-mt1,'bv-',markersize=ms,linewidth=lw,label="tot diff")
ax[2].plot_date(idx.to_pydatetime(),mut2-mut1,'rv-',markersize=ms,linewidth=lw,label="urb diff")
ax[2].xaxis.grid(True,color="k",which="major")
ax[2].xaxis.set_major_locator(dates.WeekdayLocator(byweekday=(1),interval=1))
ax[2].plot_date(idx.to_pydatetime(),[0 for i in range(dlen)],'k-')
ax[2].legend(loc='upper right')
ax[2].set_ylabel('2 m Temperature ($^\circ$C)')
#ax[0].xaxis.set_major_locator(dates.DayLocator())

ax[2].xaxis.set_major_formatter(dates.DateFormatter('%b %d'))
ax[2].xaxis.set_minor_locator(dates.DayLocator())
#ax[0].xaxis.grid(True, which="minor",linestyle='--')
ax[2].set_xlabel('2018')
plt.tight_layout()
plt.savefig('./compare_alb.png',bbox_inches='tight')
#plt.show()







