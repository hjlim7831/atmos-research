import numpy as np
import matplotlib.pyplot as plt

def phi(x,n):
	if abs(x-1/2)<1/4:
		return (np.cos(2*np.pi*(x-1/2)))**n
	else:
		return 0

def DFT_slow(x):
	x = np.asarray(x,dtype=float)
	N = x.shape[0]
	n = np.arange(N)
	k = n.reshape((N,1))
	M = np.exp(-2j*np.pi*k*n/N)
	return np.dot(M,x)

def FFT(x):
	x = np.asarray(x,dtype=float)
	N = x.shape[0]
	
	if N%2>0:
		raise ValueError("size of x must be a power of 2")
	elif N<=32:
		return DFT_slow(x)
	else:
		X_even = FFT(x[::2])
		X_odd = FFT(x[1::2])
		factor = np.exp(-2j * np.pi * np.arange(N)/N)
		return np.concatenate([X_even + factor[:int(N/2)]*X_odd, X_even + factor[int(N/2):]*X_odd])

# Reference of DFT_slow, FFT: jakevdp.github.io/blog/2013/08/28/understanding-the-fft/

def IDFT(x):
	x = np.asarray(x,dtype=float)
	N = x.shape[0]
	factor = np.exp(2j * np.pi * np.arange(N)/N)
	re = np.zeros(N,dtype='c8')
	for i in range(N):
		for j in range(N):
			re[i] += 1/N*(factor[j])**i*x[j]
	return re

#Plot log(error) vs log(dx)

nn = np.array([0,1,2])
mm = np.array([4])
nxx, dxx = 2**mm, 1/2**mm

Xmesh = np.zeros((nxx[0],3))
fft = np.zeros((nxx[0],3),dtype='c8')
idft = np.zeros((nxx[0],3),dtype='c8')

for j in range(3):
	for i in range(nxx[0]):
		xi = i*dxx[0]
		Xmesh[i,j] = phi(xi,j)
	fft[:,j] = FFT(Xmesh[:,j])
	idft[:,j] = IDFT(fft[:,j])


xx = np.array([i*dxx[0] for i in range(nxx[0])])
plt.plot(xx,idft,label="fft")
#plt.plot(xx,Xmesh,label="exact")
plt.legend()
plt.show()











