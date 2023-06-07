import numpy as np
import matplotlib.pyplot as plt
import pandas as pd
import sort_csv as sc
from sklearn.decomposition import PCA
from metpy.calc import wind_direction
from metpy.units import units

diri1 = '~/2019-win/whiteroof/'
diri2 = 'csv/'
dim = 28
sday = 15

fil1 = 'OBS_AWS_TIM_0715-0820_revised.csv'

data = pd.read_csv(diri1+diri2+fil1,sep=',',header=None)
date = data[1].values
stndata = data[0].values
rdata = data.drop([0,1],axis=1).values

b = sc.sep_csv(stndata,rdata,date)

DATE = sc.yymmddhh(2018,7,15,2018,8,20)
b.date_csv(DATE)
gdata = b.gdata

gdatam = np.average(gdata,axis=0)

pca1 = PCA(n_components=1)
X_low = pca1.fit_transform(gdatam)
X2 = pca1.inverse_transform(X_low)

plt.plot(X2[:,0],X2[:,1])





