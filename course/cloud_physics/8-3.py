import numpy as np
import matplotlib.pyplot as plt
import sys

tT = 120 #min
DT = 1. #sec

alen = int(tT*60/DT)

diam = [0.,0.1,0.2,0.3,0.4,0.5,0.6,0.7,0.8,0.9,1.0,1.2,1.4,1.6,1.8,2.0,2.2,2.4,\
		2.6,2.8,3.0,3.2,3.4,3.6,3.8,4.0,4.2,4.4,4.6,4.8,5.0,5.2,5.4,5.6,5.8]
fs = [0.,0.27,0.72,1.17,1.62,2.06,2.47,2.87,3.27,3.67,4.03,4.64,5.17,5.65,6.09,6.49,6.90,7.27,\
		7.57,7.82,8.06,8.26,8.44,8.60,8.72,8.83,8.92,8.98,9.03,9.07,9.09,9.12,9.14,9.16,9.17]

P = 800 #hPa
T = 283.15 #K
s = 0.8 #%
A = 2.53*1e+9 #hPa
B = 5420 #K
k = 0.286
ep = 0.622
cp = 1005 #J/kg/K
cw = 4187 #J/kg/K
L = 2.5*1e+6 #J/kg
Rp = 287 #J/kg/K
Rv = 461.5 #J/kg/K
rhoL = 1000 #kg/m3
K10 = 0.0248
D10 = 0.0000295
mu10 = 0.00001766 #kg/m/s
Fk = (L/(Rv*T)-1)*L*rhoL/(T*K10) #s/m2
Fd = rhoL*Rv*T/(D10*A*100*np.exp(-B/T)) #s/m2

def u(D): #D: mm
	l = len(diam)
	for i in range(l-1):
		if diam[i]<= D< diam[i+1]:
			sl = (fs[i+1]-fs[i])/(diam[i+1]-diam[i])
			y = sl*(D-diam[i])+fs[i]
			return y #m/s
			break

def delz(D,dt):
	return -u(D)*dt


def delD(D,dt,ksi):
	R = D/2
	S = 0.5
	r0 = 0.1 #mm
	return (S-1)*ksi/R*dt*1e+6*2


def nearpos(arr,value):
	l = len(arr)
	arr1 = arr - value
	v = 1e+10
	for i in range(l):
		if arr1[i] != np.nan and np.abs(arr1[i])<np.abs(v):
			v = arr1[i]
			idx = i
	return idx

t = np.array([i*DT for i in range(alen)])
D = np.full(alen,np.nan)
Z = np.full(alen,np.nan)
D[0] = 0.2
Z[0] = 0.

for i in range(alen-1):
	if D[i]>5.8 or D[i]<=0.:
		print(Z[i],"m")
		break
	dz = delz(D[i],DT)
	dD = delD(D[i],DT,1/(Fk+Fd))
	Z[i+1] = Z[i] + dz
	D[i+1] = D[i] + dD
	
plt.plot(t/60,Z)
plt.xlabel("Time (min)")
plt.ylabel("Height (m)")
#plt.xlim(0,25)
#plt.ylim(0,2)
#plt.show()
plt.savefig("./HW8-3_1.png")
plt.show()

plt.scatter(D,Z,s=1)
plt.xlabel("Diameter (mm)")
plt.ylabel("Height (m)")
#plt.xlim(0,4)
#plt.ylim(0,2)
#plt.show()
plt.savefig("./HW8-3_2.png")




