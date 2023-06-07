import numpy as np

def COEF(A,B,C,Q,Fc,T,Mc,H2Oc):
	if Q == '0':
		rate_coef = A[0] * (300/T)**B[0] * np.exp(C[0]/T)
	elif Q == '1':
		kn = A[0] * (300/T)**B[0]
		ki = A[1] * (300/T)**B[1]
		knot = kn * Mc
		rate_coef = (knot/(1+knot/ki)) * Fc[0]**(1/(1 + (np.log10(knot/ki))**2))
	elif Q == '2':
		rate_coef = (A[0] * np.exp(C[0]/T) + A[1] * Mc * np.exp(C[1]/T)) * ( 1+ A[2] * H2Oc * np.exp(C[2]/T))




