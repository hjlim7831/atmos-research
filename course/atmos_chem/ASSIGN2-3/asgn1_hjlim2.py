import numpy as np
import matplotlib.pyplot as plt

hgt = np.array([20, 30, 40, 50]) # [km]
P_z = np.array([5.53, 1.2, 0.28, 0.079], dtype = 'float64')*((10.)**(3.))
T_z = np.array([-56.5, -46.64, -22.8, -2.5], dtype = 'float64') + 273.15
w1_z = np.array([1.85, 5.3, 7.09, 7.85], dtype = 'float64')
w2_z = np.array([1.85, 2.65, 4.7, 5.79], dtype = 'float64')
J1_z = ( (100.)**(-7. + (w1_z/3.11) ) )
J2_z = ( (10.)**(-4. + (w2_z/3.11) ) )
n_z = len(hgt)

ii = 0
pa = P_z[ii]
T = T_z[ii]
J1 = J1_z[ii]
J2 = J2_z[ii]

R = 8.314
Co2, Cm = 0.21, 0.99 #mol/mol
Co3, Co = 0., 0.
k1 = 6.0e-34*(300/T)**2.3 #cm3 molec-1 s-1
k2 = 8.0e-12*(-2060/T) #cm6 molec-1 s-1
AN = 6.02e+23
CONV = 1e-6*pa*AN/(R*T) #mol/mol -> #/cm3

solO3 = 1.1e12 #molec cm-3
solNd = 2.46e19 #molec cm-3
solCo3 = 44.7 #ppbv

Ninit = np.array([Co3,Co])*CONV
print(Ninit)
Nsiz = Ninit.size
Prod = np.zeros(Nsiz)
Lamb = np.zeros(Nsiz)

t = 20000.
dt = 0.1
nt = int(t//dt)
t1 = np.arange(0,(nt)*dt,dt)

Ntot1 = np.zeros((Nsiz,nt))
Ntot1[:,0] = Ninit

for i in range(nt-1):
	Prod[0] = k1*Ntot1[1,i]*Co2*CONV*Cm*CONV
	Prod[1] = J1*Ntot1[0,i]+J2*CONV*Co2
#	Lamb[0] = k2*Ntot1[0,i]*Ntot1[1,i] + J1*Ntot1[0,i]
#	Lamb[1] = J1*Ntot1[1,i]+J2*CONV*Co2
	Lamb[0] = k2*Ntot1[1,i] + J1
	Lamb[1] = k2*Ntot1[0,i] + k1*CONV*CONV*Co2*Cm

	Ntot1[:,i+1] = (Ntot1[:,i]+dt*Prod)/(1+dt*Lamb)

Ntot1 = Ntot1*1e+2
#for NO,NO2,O3P,O3
plt.figure()
plt.plot(t1,Ntot1[0],label='O3')
plt.xlabel("time[s]")
#plt.ylabel("molar ratio[mol/mol]")
plt.ylabel("number density [#/cm3]")
plt.title("Backward Method-O3")
plt.legend()
plt.savefig("./BACK_O3.png")
plt.show()




