import numpy as np
from reader_phot2 import active_spec,rxn_ind,rnum,r_ind,wpcoef,wrcoef,react_spec,prod_spec,wrate
import sys
import matplotlib.pyplot as plt

nact = len(active_spec)

def PROD(init,rate_coef,pn,pind):
	prod = np.zeros(nact)
	for ii in range(nact):
		for i in range(pn[ii]+1):
			IND = pind[ii][i]
#			print(pind)
			rate = rate_coef[IND]
#			print(rate)
			for j in range(3):
				pIND = rxn_ind[IND][j]
				if pIND >= 0:
					rcoef = wrcoef[IND][j]
					rate *= init[pIND]**rcoef
					rate = rate * pcoef
			prod[IND] += rate
	return prod

def LOSS(init,rate_coef,rnum,r_ind):
	loss = np.zeros(nact)
	for ii in range(nact):
		for i in range(rnum[ii]+1):
			IND = r_ind[ii][i]
			rate = rate_coef[IND]
#			print(rate)
			for j in range(3):
				lIND = r_ind[IND][j]
				if lIND >= 0.:
					rcoef = wrcoef[IND][j]
					rate *= init[lIND]**rcoef
					rate = rate * rcoef
			loss[ii] += rate
	return loss

def imLOSS(init,rate_coef):
	imloss = np.zeros(nact)
	for ii in range(nact):
		for i in range(rnum[ii]+1):
			IND = r_ind[ii][i]
			losrate = rate_coef[IND]
#			print(losrate)
			for j in range(3):
				lIND = rxn_ind[IND][j]
				if lIND >= 0.:
					rcoef = wrcoef[IND][j]
					if lIND != ii:
						losrate *= init[lIND]**rcoef
						losrate = losrate * rcoef
			imloss[ii] += losrate
	return imloss





