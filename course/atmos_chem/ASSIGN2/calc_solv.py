import numpy as np
from reader_phot import pnum, rnum, p_ind, r_ind, nact, lr
from calc_pli import PROD, LOSS, imLOSS

########################### MIE ################################
def MIE(h_mie,conc,rate_coef):

# [1] Set initial estimates to initial conc ===================
	estf = np.copy(conc)
	estb = np.copy(conc)

# [2] Set maximum estimate to initial conc ====================
	estm = np.copy(conc)

	Np = 0
	iM = 100
	if lr <= 15:
		crit = 30
	else:
		crit = 5
	LT = 1e+6
	re_max = np.copy(conc)
	stat = 0
	for itr in range(iM):
		prod = PROD(estb,rate_coef,pnum,p_ind)
		loss = LOSS(estb,rate_coef,rnum,r_ind)
		imlo = imLOSS(estb,rate_coef)
		print(prod)
		print(loss)
		print(imlo)

		for j in range(nact):
			estb[j] = ( conc[j] + h_mie * prod[j])/(1. + h_mie * imlo[j])
			estf[j] = conc[j] + h_mie * (prod[j] - loss[j])

	# Method 2

		ml_lspc = []
		for i in range(nact):
			if h_mie * imlo[i] < LT:
				ml_lspc.append(i)
	
		pon = []
		for i in ml_lspc:
			if estf[i] >= 0.:
				pon.append(1)
			else:
				pon.append(0)

		if sum(pon) == len(pon) * 1:
			Np += 1
		else:
			Np = 0

		if Np == crit:
			break

		for i in range(nact):
			re_max[i] = max(conc[i],estb[i])
			estb[i] = min(estb[i],estm[i])
			estm[i] = re_max[i]

		if itr == iM-1:
			stat = 1

	for i in range(nact):
		if h_mie*imlo[i] >= LT:
			conc[i] = np.copy(estb[i])
		else:
			conc[i] = np.copy(estf[i])
	

	itr_res = {'estimate':conc,'status':stat}

	return itr_res


def Back(N0,dt,rate_coef):
	tlen = len(N0)
	prod = np.zeros(tlen)
	imlo = np.zeros(tlen)
	prod_d = PROD(N0,rate_coef,pnum,p_ind)
	imlo_d = imLOSS(N0,rate_coef)
	flen = len(prod_d)
	prod[:flen] = PROD(N0,rate_coef,pnum,p_ind)
	imlo[:flen] = imLOSS(N0,rate_coef)
	Nt = (N0 + dt*prod)/(1. + dt*imlo)
	return Nt
