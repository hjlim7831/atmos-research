import numpy as np
import matplotlib.pyplot as plt
#call variables
exec(open('drydep.py','r').read())
exec(open('emission.py','r').read())
exec(open('reader_phot.py','r').read())

"""variables
active_spec ; spec_name ; mw ; init
coefA ; coefB ; coefC ; pcoefA ; pcoefB ; pcoefC
reactants ; products ; preactants ; pproducts
react_rate ; phot_rate
react_coefs ; preact_coefs ; prod_coefs ; pprod_coefs
react_spec ; prod_spec ; preact_spec ; pprod_spec

fuction : Prod, Loss

"""
################QSSA method##################

h3 = 100 #100s
t0 = 172.*86400.
r3 = int(86400.*7./h3)
t3 = np.arange(0,(r3+1)*h3,h3)
Data3 = np.zeros((r3+1,lsn))
Data3[0] = init

for i in range(r3):
	Data3[i+1] = Data3[i] + h3*E #Emission
	for j in range(lsn): # Prod-Loss
		if h3*lamb(Data3[i+1],t0+(i+1)*h3)[j]<0.01:
			Data3[i+1][j] = Data3[i+1][j]+h3*(Prod(Data3[i+1],t0+(i+1)*h3)[j]-Loss(Data3[i+1],t0+(i+1)*h3)[j])
		elif h3*lamb(Data3[i+1],t0+(i+1)*h3)[j]>=0.01 and h3*lamb(Data3[i+1],t0+(i+1)*h3)[j]<=10.:
			Data3[i+1][j] = Data3[i+1][j]*np.exp(-1.*h3*lamb(Data3[i+1],t0+(i+1)*h3)[j]) + Prod(Data3[i+1],t0+(i+1)*h3)[j]*(1.-np.exp(-1.*h3*lamb(Data3[i+1],t0+(i+1)*h3)[j]))/lamb(Data3[i+1],t0+(i+1)*h3)[j]
		else:
			Data3[i+1][j] = Prod(Data3[i+1],t0+(i+1)*h3)[j]/lamb(Data3[i+1],t0+(i+1)*h3)[j]
	Data3[i+1] = Data3[i+1] - h3*D(Data3[i+1]) #Deposition
	if i%int(100)==0:
		print(i)
Data3t=np.transpose(Data3/CONV*10**9)
#Data3t=np.transpose(Data3)
"""
#for NO
plt.plot(t3,Data3t[spec_name.index('NO')],label='NO')
plt.xlabel("time[s]")
plt.ylabel("ppbv")
plt.title("Time series of NO")
plt.legend()
plt.show()

#for NO2
plt.plot(t3,Data3t[spec_name.index('NO2')],label='NO2')
plt.xlabel("time[s]")
plt.ylabel("ppbv")
plt.title("Time series of NO2")
plt.legend()
plt.show()

#for O3
plt.plot(t3,Data3t[spec_name.index('O3')],label='O3')
plt.xlabel("time[s]")
plt.ylabel("ppbv")
plt.title("Time series of O3")
plt.legend()
plt.show()

#for OH
plt.plot(t3,Data3t[spec_name.index('OH')],label='OH')
plt.xlabel("time[s]")
plt.ylabel("ppbv")
plt.title("Time series of OH")
plt.legend()
plt.show()

#for N2O5
plt.plot(t3,Data3t[spec_name.index('N2O5')],label='N2O5')
plt.xlabel("time[s]")
plt.ylabel("ppbv")
plt.title("Time series of N2O5")
plt.legend()
plt.show()
"""
#for all species
plt.plot(t3,Data3t[spec_name.index('NO')],label='NO')
plt.plot(t3,Data3t[spec_name.index('NO2')],label='NO2')
plt.plot(t3,Data3t[spec_name.index('O3')],label='O3')
plt.plot(t3,Data3t[spec_name.index('OH')],label='OH')
plt.plot(t3,Data3t[spec_name.index('N2O5')],label='N2O5')
plt.xlabel("time[s]")
plt.ylabel("ppbv")
plt.title("Time series of all species")
plt.legend()
plt.show()
