import numpy as np
from reader_phot import active_spec,rn,wrind,rind,wpcoef,react_spec,prod_spec
import sys
import matplotlib as plt

nact = len(active_spec)

def PROD(init,rate_coef,pn,pind):
	prod = np.zeros(nact)
	for ii in range(nact):
		for i in range(pn[ii]+1):
			IND = pind[ii][i]
			print(pind)
			rate = rate_coef[IND]
			for j in range(3):
				pIND = wrind[IND][j]
				if pIND >= 0:
					rcoef = rate_coef[IND][j]
					print("IND:",IND)
					print(len(prod_spec))
#					print(active_spec)
#					print(prod_spec[IND])
#					prIND = prod_spec[IND].index(active_spec[ii])
#					pcoef = wpcoef[IND][prIND]
					rate *= init[pIND]**rcoef
					rate *= pcoef
			prod[IND] += rate
	return prod

def LOSS(init,rate_coef,rn,rind):
	loss = np.zeros(nact)
	for ii in range(nact):
		for i in range(rn[ii]+1):
			IND = rind[ii][i]
			rate = rate_coef[IND]
			for j in range(3):
				lIND = rind[n][j]
				if lIND >= 0.:
					rcoef = rate_coef[IND][j]
					rate *= init[lIND]**rcoef
					rate *= rcoef
			loss[ii] += rate
	return loss

def imLOSS(init,rate_coef):
	imloss = np.zeros(nact)
	for ii in range(nact):
		for i in range(rn[ii]+1):
			IND = rind[ii][i]
			losrate = rate_coef[IND]
			for j in range(3):
				lIND = wrcoef[IND][j]
				if lIND >= 0.:
					rcoef = wrcoef[IND][j]
					if lIND != ii:
						losrate *= init[lIND]**rcoef
						losrate *= rcoef
			imloss[ii] += losrate
	return imloss





