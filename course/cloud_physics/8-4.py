import numpy as np
import matplotlib.pyplot as plt
import sys

tT = 40 #min
DT = 1. #sec

alen = int(tT*60/DT)

diam = [0.1,0.2,0.3,0.4,0.5,0.6,0.7,0.8,0.9,1.0,1.2,1.4,1.6,1.8,2.0,2.2,2.4,\
		2.6,2.8,3.0,3.2,3.4,3.6,3.8,4.0,4.2,4.4,4.6,4.8,5.0,5.2,5.4,5.6,5.8]
fs = [0.27,0.72,1.17,1.62,2.06,2.47,2.87,3.27,3.67,4.03,4.64,5.17,5.65,6.09,6.49,6.90,7.27,\
		7.57,7.82,8.06,8.26,8.44,8.60,8.72,8.83,8.92,8.98,9.03,9.07,9.09,9.12,9.14,9.16,9.17]

def u(D): #D: mm
	l = len(diam)
	for i in range(l-1):
		if diam[i]<= D< diam[i+1]:
			sl = (fs[i+1]-fs[i])/(diam[i+1]-diam[i])
			y = sl*(D-diam[i])+fs[i]
			return y #m/s
			break

def delz(D,dt):
	return (4.0-u(D))*dt


def delD(D,dz):
	M = 1.5*1e-3 #kg/m3
	E = 1. #fraction
	rhoL = 1000. #kg/m3
	uu = u(D)
	U = 4.0 #m/s
	return E*M/(rhoL*2)*uu/(U-uu)*dz*1e+3


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
	if D[i] <0.1 or D[i]>5.8:
		break
	dz = delz(D[i],DT)
	dD = delD(D[i],dz)
	Z[i+1] = Z[i] + dz
	D[i+1] = D[i] + dD
	
plt.plot(t/60,Z/1000)
plt.xlabel("Time (min)")
plt.ylabel("Height (km)")
plt.xlim(0,25)
plt.ylim(0,2)
plt.savefig("./HW8-4_1.png")
plt.show()

plt.scatter(D,Z/1000,s=1)
plt.xlabel("Diameter (mm)")
plt.ylabel("Height (km)")
plt.xlim(0,4)
plt.ylim(0,2)
plt.savefig("./HW8-4_2.png")
plt.show()

for i in range(alen):
	MZ = max(Z)
	if MZ == Z[i]:
		D_MZ = D[i]

print(MZ)
print("the size of the drop at the top of its trajectory:",D_MZ,"mm")

trunc = 10

idz_z0 = nearpos(Z[trunc:],0.)
print(idz_z0)
print("Z:",Z[trunc+idz_z0]/1000,"km")
print("D:",D[trunc+idz_z0],"mm")
print("t:",t[trunc+idz_z0]/60,"min")





