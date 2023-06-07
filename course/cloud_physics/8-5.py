import numpy as np
import matplotlib.pyplot as plt
import sys

tT = 10 #min
DT = 0.05 #sec

alen = int(tT*60/DT)

rad = [0.,20.,30.,40.] #micro m
coll = [0.,0.17,0.37,0.55] #fraction

T = 283.15 #K assumption (10 degree)
s = 0.2 #%
M = 1*1e-3 #kg/m3
r0 = 10. #micro m
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
ksi = s*1e-2/(Fk+Fd)
k3 = 8000 #/s

def E(R): #D: mm
	l = len(rad)
	for i in range(l-1):
		if rad[i]<= R< rad[i+1]:
			sl = (coll[i+1]-coll[i])/(rad[i+1]-rad[i])
			y = sl*(R-rad[i])+coll[i]
			return y #m/s
			break

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
R = np.full(alen,np.nan)
R[0] = r0

r0r = r0*1e-6
for i in range(alen-1):
	if R[i]>=40 or R[i]<=0.:
		break
	Rr = R[i]*1e-6
	dRdT = (k3*(Rr-r0r)*((Rr+r0r)/Rr)**2*M/rhoL*E(R[i])+ksi/Rr)*1e+6
#	dRdT = k3*R[i]*((R[i]+r0)/R[i])**2*M/rhoL*E(R[i])+ksi/R[i]
	dR = dRdT * DT
	R[i+1] = R[i] + dR
	
plt.plot(t/60,R)
plt.xlabel("Time (min)")
plt.ylabel("Radius ($\mu m$)")
#plt.xlim(0,25)
#plt.ylim(0,2)
#plt.show()
plt.savefig("./HW8-5.png")
#plt.show()

idx20 = nearpos(R,20)
idx30 = nearpos(R,30)
idx40 = nearpos(R,40)

print(t[idx20]/60)
print(t[idx30]/60)
print(t[idx40]/60)




