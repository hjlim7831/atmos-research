from __future__ import print_function
from netCDF4 import Dataset
from wrf import ll_to_xy, getvar
import numpy as np
import scipy.interpolate

def intp_valid(Path,mlat,mlon,var,dis=1): #mlat, mlon: ndarray / file, var: "string"
	ncfile = Dataset(Path)
	xlat = getvar(ncfile,"lat")
	xlon = getvar(ncfile,"lon")
	v = getvar(ncfile,var)
	mi, mj = ll_to_xy(ncfile,mlat,mlon)
	dim = len(mlat)
	size = (2*dis+1)**2
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
	return varr	
