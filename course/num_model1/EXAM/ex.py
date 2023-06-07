import numpy as np
import matplotlib.pyplot as plt

def phi(x,n):
	if abs(x-1/2)<1/4:
		return (np.cos(2*np.pi*(x-1/2)))**n
	else:
		return 0


dx = 1/16
nx = 16
Xmesh = np.zeros(nx)
for i in range(nx):
	xi = i*dx
	Xmesh[i] = phi(xi,0)

fft = np.fft.fft(Xmesh)
idft = np.fft.ifft(fft)
print(Xmesh)
print(idft.real)

plt.plot([i*dx for i in range(nx)],idft,label="FFT")
plt.plot([i*dx for i in range(nx)],Xmesh,label="exact")
plt.legend()
plt.show()





