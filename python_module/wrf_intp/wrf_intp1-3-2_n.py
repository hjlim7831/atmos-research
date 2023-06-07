from __future__ import print_function
from netCDF4 import Dataset
from wrf import ll_to_xy, getvar, ALL_TIMES
import numpy as np
import scipy.interpolate

def intp_valid(Path,mlat,mlon,var,tidx=ALL_TIMES,dis=1): #mlat, mlon: ndarray / file, var: "string"
	ncfile = Dataset(Path)
	xlat = getvar(ncfile,"lat")
	xlon = getvar(ncfile,"lon")
#	lu = getvar(ncfile,"LU_INDEX") # added
	v = getvar(ncfile,var,timeidx=tidx)
	mi, mj = ll_to_xy(ncfile,mlat,mlon)
	dim = len(mlat)
	size = (2*dis+1)**2
	if tidx == ALL_TIMES or tidx<0:
		vsiz = len(v[:,0,0])
		if dim >1:
			varr = np.zeros((dim,vsiz))
			for i in range(dim):
				print(i)
				ii = int(mi[i])
				ij = int(mj[i])
				lat = float(mlat[i])
				lon = float(mlon[i])
				tlat = np.array(xlat[ij-dis:ij+dis+1,ii-dis:ii+dis+1])
				tlon = np.array(xlon[ij-dis:ij+dis+1,ii-dis:ii+dis+1])
				n = 0
				for j in range(2*dis):
					for k in range(2*dis):
						tr1, tr2 = False, False
						slat = [tlat[j,k], tlat[j,k+1], tlat[j+1,k], tlat[j+1,k+1]]
						slon = [tlon[j,k], tlon[j,k+1], tlon[j+1,k], tlon[j+1,k+1]]
						slat.sort()
						slon.sort()
						for l in range((2*dis)**2-1):
							if slat[l] <= lat < slat[l+1]:
								tr1 = True
							if slon[l] <= lon < slon[l+1]:
								tr2 = True
						n += 1
						if tr1 and tr2:
							break
					if tr1 and tr2:
						break
				tv = np.array(v[:,ij-dis+j:ij-dis+j+2,ii-dis+k:ii-dis+k+2]).reshape((vsiz,4*dis**2))
				ll = list(zip(tlat[j:j+2,k:k+2].reshape(4*dis**2),tlon[j:j+2,k:k+2].reshape(4*dis**2)))
				for j in range(vsiz):
					interp = scipy.interpolate.LinearNDInterpolator(ll,tv[j,:])
					varr[i,j] = interp(lat,lon)
					

#				print(lu[ij-dis:ij+dis+1,ii-dis:ii+dis+1]) #added
#				tv = np.array(v[:,ij-dis:ij+dis+1,ii-dis:ii+dis+1]).reshape((vsiz,size))
#				ll = list(zip(tlat,tlon))
#				for j in range(vsiz):
#					interp = scipy.interpolate.LinearNDInterpolator(ll,tv[j,:])
#					varr[i,j] = interp(lat,lon)
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
			varr = np.zeros(1)
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
