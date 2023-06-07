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
	n = np.arange(N)
	k = n.reshape((N,1))
	M = np.exp(2j*np.pi*k*n/N)
	return 1/N*np.dot(M,x)

#Plot log(error) vs log(dx)
nn = np.array([0,1,2])
mm = np.array([i+3 for i in range(8)])
#mm = np.array([i+3 for i in range(6)])
nxx, dxx = 2**mm, 1/2**mm
lm, ln = len(mm), len(nn)
error = np.zeros((2,3,lm))

for k in range(lm):
	print(k)
	Xmesh = np.zeros((nxx[k],3))
	fft = np.zeros((nxx[k],3),dtype='c8')
	idft = np.zeros((nxx[k],3),dtype='c8')
	iis = int((3/8)/dxx[k])
	iie = int((5/8)/dxx[k])+1

	for j in range(ln):
		for i in range(nxx[k]):
			xi = i*dxx[k]
			Xmesh[i,j] = phi(xi,nn[j])
		fft[:,j] = FFT(Xmesh[:,j])
		idft[:,j] = IDFT(fft[:,j]).real
		error[0,j,k] = max(abs(idft[:,j]-Xmesh[:,j]))
		error[1,j,k] = max(abs(idft[iis:iie,j]-Xmesh[iis:iie,j]))
		print(error[:,j,k])

print(error)

ss = 30
cl1 = ["red","blue","green"]
cl2 = ["brown","tab:cyan","lime"]
for k in range(ln):
	plt.scatter(dxx,error[0,k,:],s=ss,c=cl1[k],marker="+")
	plt.scatter(dxx,error[1,k,:],s=ss,c=cl2[k],marker=".")

Me = np.max(error)
me = np.min(error)
Md = np.max(dxx)
md = np.min(dxx)

plt.ylim(5e-9,Me*2)
plt.xlim(md/2,Md*2)
plt.yscale("log")
plt.xscale("log")
plt.xlabel("$\Delta$x")
plt.ylabel("error")
plt.savefig("./final_8-1.png")
plt.show()


#Plot exact and approximate solutions (when dx=1/16)
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
fig, axes = plt.subplots(3)

lw = 1
ms = 1.4

for i in range(3):
	axes[i].plot(xx,idft.real[:,i],"bo-",label="FFT",linewidth=lw,markersize=ms)
	axes[i].plot(xx,Xmesh[:,i],"ko-",label="exact",linewidth=lw,markersize=ms)

plt.legend()
plt.savefig("./final_8-2.png")
plt.show()











