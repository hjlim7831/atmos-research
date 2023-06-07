from pandas.plotting import register_matplotlib_converters
import datetime
import pandas as pd
import matplotlib.pyplot as plt
import matplotlib.dates as dt

register_matplotlib_converters()

df1= pd.read_csv('./csv/META_whole_ASOS_time_2020-02-17.csv',na_values='')

df = df1.fillna(datetime.datetime.now())
#print(df)


df.amin = pd.to_datetime(df.amin)
df.amax = pd.to_datetime(df.amax)


fig = plt.figure(figsize=(6,35))
ax = fig.add_subplot(111)
ax = ax.xaxis_date()
#ax = plt.hlines(df.stnnum, dt.date2num(df.amin), dt.date2num(df.amax))
#ax = plt.yticks(df.stnnum,fontsize=4,rotation=45)
for i,stn in enumerate(df.stnnum):
	x = dt.date2num(df.amin)[i]
	x1 = dt.date2num(df.amax)[i]
	y = df.stnnum[i]
	plt.hlines(y,x,x1)
	plt.text(x,y+0.3,stn)
plt.axvline(x=datetime.datetime(1973,1,1),color='r')
plt.axvline(x=datetime.datetime(2019,12,31),color='r')

plt.savefig('./Timeline.png')

#plt.show()


