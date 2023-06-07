import numpy as np
import matplotlib.pyplot as plt
import sys

N = 25

Tbox = np.array([-23+i for i in range(8)]) # Celcius
wsbox = np.array([1.002, 1.094, 1.194, 1.303, 1.420, 1.546, 1.682, 1.824]) #g/kg
wibox = np.array([0.800, 0.883, 0.973, 1.072, 1.179, 1.296, 1.425, 1.565]) #g/kg

cp = 1005 # J/kg/K
A = 2.53*1e+9 #hPa
B = 5420 #K
Lf = 3.3*1e+2 # J/g
L = 2.5*1e+3 #J/g
Ls = 2.83*1e+3 #J/g
T0 = -20 # Celcius
LWC0 = 3 #g/kg
P = 600 #hPa

def WS(T):
	l = len(wsbox)
	for i in range(l-1):
		if Tbox[i]<= T <Tbox[i+1]:
			sl = (wsbox[i+1]-wsbox[i])/(Tbox[i+1]-Tbox[i])
			y = sl*(T-Tbox[i])+wsbox[i]
			return y #g/kg
			break

def WI(T):
	l = len(wibox)
	for i in range(l-1):
		if Tbox[i]<= T <Tbox[i+1]:
			print(i)
			sl = (wibox[i+1]-wibox[i])/(Tbox[i+1]-Tbox[i])
			y = sl*(T-Tbox[i])+wibox[i]
			return y #g/kg
			break

Tarr = np.full(2*N,np.nan)
warr = np.full(2*N,np.nan) #gas
wiarr = np.full(2*N,np.nan) #ice
LWCarr = np.full(2*N,np.nan) #liquid
Tarr[0] = T0
LWCarr[0] = LWC0
warr[0] = 0.622*A*np.exp(-B/(T0+273.15))/P*1e+3
wiarr[0] = 0.

print(warr[0])

for i in range(0,N):
	print(Tarr[i])
	if -23<Tarr[i]<-16:
		dw1, dw2, dT1, dT2, dLWC, dwi, wb = 0., 0., 0., 0., 0., 0., 0.
		print(LWCarr[i],WS(Tarr[i]))
		if LWCarr[i]>WS(Tarr[i]): #from liquid to vapour -> cooling gas
			LWCarr[i+1] = WS(Tarr[i])
			dLWC = LWCarr[i+1] - LWCarr[i] #dLWC<0
			dw1 = -dLWC
			dT1 = -L/cp*dw1
			wb = warr[i] + dw1
			print(wb,WI(Tarr[i]))
		if wb>WI(Tarr[i]):  #from gas to ice -> heating gas
			dw2 = WI(Tarr[i]) - wb
			dwi = -dw2
			dT2 = -Ls/cp*dw2
		if dT1 == 0 and dT2 == 0:
			break
		print(dw1, dw2, dT1, dT2, dLWC, dwi)
		Tarr[i+1] = Tarr[i] + dT1 + dT2
		warr[i+1] = warr[i] + dw1 + dw2
		wiarr[i+1] = wiarr[i] + dwi
		LWCarr[i+1] = LWCarr[i] + dLWC
	else:
		break


print(Tarr)
print(warr)
print(LWCarr)
print(wiarr)

fig, ax1 = plt.subplots()
ax1.plot([i for i in range(2*N)],warr,label="w")
ax1.plot([i for i in range(2*N)],wiarr,label="wi")
ax1.plot([i for i in range(2*N)],LWCarr,label="LWC")
ax1.set_ylabel("(g/kg)")
plt.legend(loc = "lower right")
ax1.set_xlabel("time step")

ax2 = ax1.twinx()
ax2.plot([i for i in range(2*N)],Tarr,color="r",label="T")
ax2.set_ylabel("T($^o C$)")
plt.legend()
plt.tight_layout()
plt.savefig("HW14-2.png")
plt.show()

plt.plot([i for i in range(2*N)],Tarr)









