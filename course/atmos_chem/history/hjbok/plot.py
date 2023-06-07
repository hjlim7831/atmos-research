import numpy as np
import matplotlib.pyplot as plt
import matplotlib.dates as dt
import dateutil
import datetime
import sys
import matplotlib.pyplot as plt




startday = datetime.datetime(2016,6,15,9,0,0)
lastday = datetime.datetime(2016,6,17,21,0,0)
delta = datetime.timedelta(hours=1)

minday = np.copy(startday)
times = []
rawtimes = []
while startday <= lastday:
 rawtimes.append(dt.date2num(startday))
 times.append(startday.strftime('%m/%d %H'))
 startday += delta

hours = dt.HourLocator()
seconds = dt.SecondLocator()

t = np.arange(1201)
#dates = [dateutil.parser.parse(s) for s in times]
fig = plt.figure()
ax = plt.gca()
ax.xaxis.set_major_locator(hours)
ax.xaxis.set_minor_locator(seconds)
#ax.set_xlim(min,lastday)
plt.plot(t)


# PLOT

#times = np.linspace(9., end_t/3600.+9., len(timeseries))


#spc = [0,1,2,3,4,5,6,7,8,9,10,12,13,14,15]
#for i in range(nact):
# fig, ax1 = plt.subplots(figsize=(4,5))
# ax1.set_title(act[i])
# plt.xlabel('Time [LST]',fontsize=10)
# plt.ylabel('Number Density',fontsize=10)
# plt.plot(times,timeseries[:,i],linewidth='2')
# plt.xlim(times[0],times[len(times)-1])
# plt.show()
# fig_name = act[spc[i]]+'.png'
# fig.savefig(fig_name)

#nox = timeseries[:,1]+timeseries[:,0]+timeseries[:,2]+timeseries[:,3]+timeseries[:,4]+timeseries[:,5]+timeseries[:,6]

#fig, ax1 = plt.subplots(figsize=(4,5))
#ax1.set_title('Total N')
#plt.xlabel('Time [LST]',fontsize=15)
#plt.ylabel('Number Density',fontsize=15)
#plt.plot(times,nox,linewidth='2')
#plt.xlim(times[0],times[len(times)-1])
#plt.show()
#fig_name = 'totn.png'
#fig.savefig(fig_name)
