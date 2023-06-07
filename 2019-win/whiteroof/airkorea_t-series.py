
import sort_csv as sc
import pandas as pd
import numpy as np
import matplotlib.pyplot as plt
import matplotlib.dates as dates
from metpy.calc import wind_direction
from metpy.units import units
import datetime
import sys

def make_patch_spines_invisible(ax):
	ax.set_frame_on(True)
	ax.patch.set_visible(False)
	for sp in ax.spines.values():
		sp.set_visible(False)

diri1 = '~/2019-win/whiteroof/'
diri2 = 'csv/'
dim = 1
#sday = 15
#eday = 31+20
sday = 21
eday = 27

dlen = (eday -sday +1)*24


sdt = (sday-1)*24 -1 # for Air Korea
edt = eday*24 -1

sdt1 = (sday -15)*24
edt1 = (eday -14)*24

fil3 = 'jungu_2018-3.csv'
fil2 = 'ASOS_0715-0820_forValid_revised.csv'


adata = pd.read_csv(diri1+diri2+fil3,sep=',')
mdata = pd.read_csv(diri1+diri2+fil2,sep=',',header=None)


#date = adata['date']
NO2 = adata['NO2'][sdt:edt]
O3 = adata['O3'][sdt:edt]

#print(date[sdt:edt])

date = mdata[1]
stndata = mdata[0]
rdata = mdata.drop([0,1],axis=1)
rd = rdata.values
sd = stndata.values
dd = date.values


b = sc.sep_csv(sd,rd,dd)

DATE = sc.yymmddhh(2018,7,15,2018,8,20)

b.date_csv(DATE)
gdata = b.gdata[sdt1:edt1,0]

#print(DATE[sdt1:edt1])


##I have, gdata(ASOS) & NO2, O3
#ms = 1.2
#lw = 0.7
#lo = "upper left"
filnam = "./pollution_series_0714-0820.png"

ms = 3.
lw = 1.5
lo = "upper right"
filnam = "./pollution_series_0721-0727.png"

#idx = pd.date_range("2018-07-15 00:00:00",periods=dlen,freq='H')
idx = pd.date_range("2018-07-21 00:00:00",periods=dlen,freq='H')

fig, host = plt.subplots(figsize=(20,3))
fig.subplots_adjust(right=0.88,bottom=0.2)

ax1 = host.twinx()
ax2 = host.twinx()

ax2.spines["right"].set_position(("axes", 1.05))
make_patch_spines_invisible(ax2)
ax2.spines["right"].set_visible(True)

p1, = host.plot_date(idx.to_pydatetime(),gdata,'ro-',markersize=ms,linewidth=lw,label="T2")
p2, = ax1.plot_date(idx.to_pydatetime(),O3,'bo-',markersize=ms,linewidth=lw,label="O3")
p3, = ax2.plot_date(idx.to_pydatetime(),NO2,'go-',markersize=ms,linewidth=lw,label="NO2")
ax1.plot_date(idx.to_pydatetime(),[0.1 for i in range(dlen)],'navy')

#ax1.xaxis.set_major_locator(dates.WeekdayLocator(byweekday=(1),interval=1))
ax1.xaxis.set_major_formatter(dates.DateFormatter('%b %d'))
#ax1.xaxis.set_minor_locator(dates.DayLocator())
ax1.xaxis.set_major_locator(dates.DayLocator())

host.xaxis.grid(True, color='k',which="major")
host.xaxis.grid(True, color='lightgray',which="minor")
host.set_xlabel('2018')
#host.set_xlim([datetime.date(2018,7,15),datetime.date(2018,8,20)])


host.set_ylabel("Temperature")
ax1.set_ylabel("Ozone (ppm)")
ax2.set_ylabel("Nitrogen dioxide (ppm)")

host.yaxis.label.set_color(p1.get_color())
ax1.yaxis.label.set_color(p2.get_color())
ax2.yaxis.label.set_color(p3.get_color())

tkw = dict(size=4, width=1.5)
host.tick_params(axis='y', colors=p1.get_color(), **tkw)
ax1.tick_params(axis='y', colors=p2.get_color(), **tkw)
ax2.tick_params(axis='y', colors=p3.get_color(), **tkw)
host.tick_params(axis='x', **tkw)


lines = [p1,p2,p3]

host.legend(lines,[l.get_label() for l in lines],loc=lo)

plt.savefig(filnam)
plt.show()



