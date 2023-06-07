import numpy as np
from math import *




def calc_coeff(A,B,C,Q,Fc,T,M_conc,H2O_conc):

  if Q == '0':
     rate_co = A[0] * (300/T)**B[0] * e**(C[0]/T)
  if Q == '1':
     kn = A[0] * (300/T)**B[0]
     ki = A[1] * (300/T)**B[1]
     knot = kn * M_conc
     rate_co = ( knot/(1 + knot/ki) ) * Fc[0]**( 1/(1 + (log10(knot/ki))**2) )
  elif Q == '2':
     rate_co = ( A[0] * e**(C[0]/T) + A[1] * M_conc * e**(C[1]/T) ) * ( 1 + A[2] * H2O_conc * e**(C[2]/T) )

  return rate_co


