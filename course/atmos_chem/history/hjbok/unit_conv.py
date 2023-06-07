import numpy as np
from math import *

# Unit conversion 
# type = ['nd2mr', 'mr2nd']

def unit_conv(A,nlev,Nd,type):

# result = np.zeros(nlev,dtype='d')

 # number density -> mixing ratio
 if type == 'nd2mr':
  for i in range(nlev):
   A[i] = A[i] / Nd[i]
 
 # mixing ratio -> number denstiy
 if type == 'mr2nd':
  for i in range(nlev):
   A[i] = A[i] * Nd[i]

 return A
