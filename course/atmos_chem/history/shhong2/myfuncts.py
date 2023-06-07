# If you use functions in this file,
#	You must import following mudules.
import math 
import numpy as np
import copy

# Forward Euler method. 
def ForEul(N_0,dt,P,gamma) :
	N_t = N_0 + dt*( P - gamma*N_0 )
	return N_t


# Backward Euler method.
def BacEul(N_0,dt,P,gamma) :
    N_t = (N_0 + dt*P)/(1. + dt*gamma)
    return N_t


# Simple Exponential Solution.
def SimExp(N_0,dt,P,gamma) :
	e = math.e
	N_t = N_0*(e**(-dt*gamma)) + (P/gamma)*( 1 - (e**(-dt*gamma)) )
	return N_t

# Quasi-Steady State Approximation.
def QSSA(N_0,dt,P,gamma) :
	crit = gamma*dt	   # criteria
	dims = crit.shape
	n_spi = dims[0]
	N_t = np.ones(n_spi)
	for i in range(n_spi):
		if (crit[i] < 0.01) : 
			N_t[i] = ForEul(N_0[i],dt,P[i],gamma[i])
		elif (0.01 <= crit[i] <= 10) :
			N_t[i] = SimExp(N_0[i],dt,P[i],gamma[i])
		else :
			N_t[i] = P[i]/gamma[i]
	return N_t


# MIE method.
def MIE(N_0,dt,k_arr,react_arr,react_arr_gam,prod_arr,loss_arr) :
	Num_p = 30
	num_p = 0
	L_t = (10.)**(2.)
	max_iter = 200
	N_max_pre = copy.deepcopy(N_0)
	N_b_pre = copy.deepcopy(N_0)
	for i in range(0, max_iter):
		
		# First, Calculate "prod_rate" & "loss_rate".
		react_rate = k_arr*np.prod(N_b_pre**react_arr, axis=1)
		react_rate_gam = k_arr*np.prod(N_b_pre**react_arr_gam, axis=2)
		prod_rate = np.sum(react_rate*prod_arr.T, axis=1)
		loss_gamm = np.sum(react_rate_gam*loss_arr.T, axis=1)

		# Calculate N_b, N_f.
		N_b_new = BacEul(N_0,dt,prod_rate,loss_gamm)
		#print('before :',N_b_new)
		N_f_new = ForEul(N_0,dt,prod_rate,loss_gamm)
		criteria =  dt*loss_gamm
		#print('N_f_new :', N_f_new)
		#print('criteria :', criteria)
		# Whether reset or not.
		if any((N_f_new < 0)*(criteria < L_t)):
			num_p = 0
		else:
			num_p = num_p + 1
		#print(num_p)

		# Check convergence.
		if (num_p==Num_p):
			Nnew = np.where(criteria < L_t, N_f_new, N_b_new)
			return Nnew
			break
		else:
			N_max_new = np.maximum(N_b_new, N_0)
			N_b_new = np.minimum(N_b_new, N_max_pre)
		
		# iteration update.
		N_b_pre = copy.deepcopy(N_b_new)
		N_max_pre = copy.deepcopy(N_max_new)

		# if not converged until "max_iter".
		if (i==(max_iter-1)):
			print("MIE solution didn't converged")
			print("dt should be more small.")







