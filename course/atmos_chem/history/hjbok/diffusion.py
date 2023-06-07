import numpy as np
from math import *

def diffusion(nlev,nact,h,dz,lev):


 # Calculate diffusion coefficient (m2/s)
 Kz = np.zeros(nlev, dtype='d')
 for i in range(nlev):
  Kz[i] = 10.*np.exp(-2.*lev[i]/lev[nlev]) 

 # IMPLICIT SOLUTION SCHEME

 Az = np.zeros((nlev,nact),dtype='d')
 Bz = np.zeros((nlev,nact),dtype='d')
 Dz = np.zeros((nlev,nact),dtype='d')

 # Arrange tridiagonal matrix

 for i in range(nact):

  # Set boundary conditions
  Az[0,i] = -h*(Kz[0]/(dz[0]**2))
# Az[0,i] = 0.
  Bz[0,i] = 1. + h*(2*Kz[0]/(dz[0]**2))
  Dz[0,i] = -h*(Kz[0]/(dz[0]**2))
  Az[nlev-1,i] = -h*(Kz[nlev-1]/(dz[nlev-1]**2))
  Bz[nlev-1,i] = 1. + h*(2*Kz[nlev-1]/(dz[nlev-1]**2))
  Dz[nlev-1,i] = 0.

  for z in range(1,nlev-1):
   Az[z,i] = -h*(Kz[z]/(dz[z]**2))
   Bz[z,i] = 1. + h*(2*Kz[z]/(dz[z]**2))
   Dz[z,i] = -h*(Kz[z]/(dz[z]**2))

 return (Az, Bz, Dz)























