import numpy as np
import matplotlib.pyplot as plt

pa = 1013 #hPa
T = 298 #K
R = 8.314
Cno, Cno2 = 5*1e-12, 10 *1e-12 #mol/mol
Co2, Cm = 0.21, 0.99 #mol/mol
Co3, Co = 0., 0.
k1 = 1.8e-14 #cm3 molec-1 s-1
k3 = 6.0e-34*(300/T)**2.3 #cm6 molec-1 s-1
J = 0.01 #s-1
k1t = 1.8e-12*np.exp(-1370/T)
AN = 6.02e+23
CONV = 1e-6*pa*AN/(R*T) #mol/mol -> #/cm3

solO3 = 1.1e12 #molec cm-3
solNd = 2.46e19 #molec cm-3
solCo3 = 44.7 #ppbv

Ninit = np.array([Cno,Cno2,Co3,Co])*CONV
print(Ninit)
Nsiz = Ninit.size
Prod = np.zeros(Nsiz)
Lamb = np.zeros(Nsiz)

t = 600.
dt = 0.01
nt = int(t//dt)
t1 = np.arange(0,(nt)*dt,dt)

Ntot1 = np.zeros((Nsiz,nt))
Ntot1[:,0] = Ninit

for i in range(nt-1):
	Prod[0] = J*Ntot1[1,i]
	Prod[1] = k1*Ntot1[0,i]*Ntot1[2,i]
	Prod[2] = k3*Co2*CONV*Cm*CONV*Ntot1[3,i]
	Prod[3] = Prod[0]
	Lamb[0] = k1*Ntot1[2,i]
	Lamb[1] = J
	Lamb[2] = k1*Ntot1[0,i]
	Lamb[3] = k3*Co2*CONV*Cm*CONV

	Ntot1[:,i+1] = (Ntot1[:,i]+dt*Prod)/(1+dt*Lamb)

Ntot1 = Ntot1*1e+2
#for NO,NO2,O3P,O3
plt.figure()
plt.plot(t1,Ntot1[0],label='NO')
plt.plot(t1,Ntot1[1],label='NO2')
plt.plot(t1,Ntot1[2],label='O3P')
plt.plot(t1,Ntot1[3],label='O3')
plt.xlabel("time[s]")
#plt.ylabel("molar ratio[mol/mol]")
plt.ylabel("number density [#/cm3]")
plt.title("Backward Method-NO,NO2,O3,O3P")
plt.legend()
plt.savefig("./BACK_4spc.png")
#plt.show()




