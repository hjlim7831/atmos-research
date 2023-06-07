from __future__ import print_function
from netCDF4 import Dataset
from wrf import ll_to_xy, getvar, ALL_TIMES
import numpy as np
import scipy.interpolate

def intp_valid(Path,mlat,mlon,var,tidx=ALL_TIMES,dis=1): #mlat, mlon: ndarray / file, var: "string"
	ncfile = Dataset(Path)
	xlat = getvar(ncfile,"lat")
	xlon = getvar(ncfile,"lon")
	v = getvar(ncfile,var,timeidx=tidx)
	mi, mj = ll_to_xy(ncfile,mlat,mlon)
	dim = len(mlat)
	size = (2*dis+1)**2
	if tidx == ALL_TIMES or tidx<0:
		vsiz = len(v[:,0,0])
		if dim >1:
			varr = np.zeros((dim,vsiz))
			for i in range(dim):
				ii = int(mi[i])
				ij = int(mj[i])
				lat = float(mlat[i])
				lon = float(mlon[i])
				tlat = np.array(xlat[ij-dis:ij+dis+1,ii-dis:ii+dis+1]).reshape(size)
				tlon = np.array(xlon[ij-dis:ij+dis+1,ii-dis:ii+dis+1]).reshape(size)
				tv = np.array(v[:,ij-dis:ij+dis+1,ii-dis:ii+dis+1]).reshape((vsiz,size))
				ll = list(zip(tlat,tlon))
				for j in range(vsiz):
					interp = scipy.interpolate.LinearNDInterpolator(ll,tv[j,:])
					varr[i,j] = interp(lat,lon)
		else:
			varr = np.zeros(vsiz)
			ii = int(mi)
			ij = int(mj)
			lat = float(mlat)
			lon = float(mlon)
			tlat = np.array(xlat[ij-dis:ij+dis+1,ii-dis:ii+dis+1]).reshape(size)
			tlon = np.array(xlon[ij-dis:ij+dis+1,ii-dis:ii+dis+1]).reshape(size)
			tv = np.array(v[:,ij-dis:ij+dis+1,ii-dis:ii+dis+1]).reshape((vsiz,size))
			ll = ll = list(zip(tlat,tlon))
			for j in range(vsiz):
				interp = scipy.interpolate.LinearNDInterpolator(ll,tv[j,:])
				varr[j] = interp(lat,lon)
	else:
		if dim >1:
			varr = np.zeros(dim)
			for i in range(dim):
				ii = int(mi[i])
				ij = int(mj[i])
				lat = float(mlat[i])
				lon = float(mlon[i])
				tlat = np.array(xlat[ij-dis:ij+dis+1,ii-dis:ii+dis+1]).reshape(size)
				tlon = np.array(xlon[ij-dis:ij+dis+1,ii-dis:ii+dis+1]).reshape(size)
				tv = np.array(v[ij-dis:ij+dis+1,ii-dis:ii+dis+1]).reshape(size)
				ll = list(zip(tlat,tlon))
				interp = scipy.interpolate.LinearNDInterpolator(ll,tv)
				varr[i] = interp(lat,lon)
		else:
			varr = nnp.zeros(1)
			ii = int(mi)
			ij = int(mj)
			lat = float(mlat)
			lon = float(mlon)
			tlat = np.array(xlat[ij-dis:ij+dis+1,ii-dis:ii+dis+1]).reshape(size)
			tlon = np.array(xlon[ij-dis:ij+dis+1,ii-dis:ii+dis+1]).reshape(size)
			tv = np.array(v[:,ij-dis:ij+dis+1,ii-dis:ii+dis+1]).reshape((vsiz,size))
			ll = ll = list(zip(tlat,tlon))
			interp = scipy.interpolate.LinearNDInterpolator(ll,tv)
			varr = interp(lat,lon)
	return varr	
