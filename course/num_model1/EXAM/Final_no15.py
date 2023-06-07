import numpy as np
import matplotlib.pyplot as plt

#periodic
L = 2
#(a)
nx = 64
dx = L/nx
cmesh, imesh = np.zeros(nx), np.zeros(nx)

def c(x):
	if 1/3<=x<=2/3:
		return 0.3-1.5*(x-1/3)*np.sin(3*np.pi*x)*np.sin(12*np.pi*x)
	else:
		return 0.3

def init(x):
	if abs(x-1/8)<=1/8:
		return 1/4*(np.cos(8*np.pi*(x-1/8))+1)**2
	else:
		return 0
def dinit(x):
	if abs(x-1/8)<=1/8:
		return 


for i in range(nx):
	x = i*dx
	cmesh[i] = c(x)
	imesh[i] = init(x)

cM = np.max(cmesh)
dt = dx/cM*0.3

##1) Spectral Methods




##2) pseudo-Spectral Methods








