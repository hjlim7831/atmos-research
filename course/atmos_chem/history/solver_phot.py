import numpy as np
import matplotlib.pyplot as plt
#call variables
exec(open('reader_phot2.py','r').read())
"""variables
active_spec ; spec_name ; mw ; init
coefA ; coefB ; coefC ; pcoefA ; pcoefB ; pcoefC
reactants ; products ; preactants ; pproducts
react_rate ; phot_rate
react_coefs ; preact_coefs ; prod_coefs ; pprod_coefs
react_spec ; prod_spec ; preact_spec ; pprod_spec

fuction : Prod, Loss

we want to solve
NO + O3 -> NO2 + O2 	k1
O2 + O3P + M -> O3 	k2
NO2 -> NO + O3P		J

h: time interval
"""
"""
#forward method
#O3(n+1) = O3(n)+ h*[Prod()-Loss()]
h1 = 2.5/100000.
r1 = int(2e+7)
#r1 = int(5e+5)
t1 = np.arange(0,(r1+1)*h1,h1)
t11 = np.arange(0,(r1)*h1,h1*1000)
Data1=np.zeros((r1+1,len(spec_name)))
Data1t=np.zeros((len(spec_name),r1/1000))
gar=np.zeros(len(spec_name))
Data1[0] = init
for i in range(r1):
	Data1[i+1] = (Data1[i]+h1*(Prod(Data1[i])-Loss(Data1[i])))
	for j in range(len(spec_name)):
		Data1t[j][i/1000]=Data1[int(i/1000)*1000][j]
	if i%int(1e+6)==0:
		print(i)
"""
"""
#for all species
for i in range(len(spec_name)):
       plt.plot(t1,Data1t[i],label=spec_name[i])
plt.xlabel("time[s]")
plt.ylabel("molar ratio[mol/mol]")
plt.title("Forward Method-all species")
plt.legend()
plt.show()
"""
"""
#for NO,NO2,O3P,O3
plt.plot(t11,Data1t[0]/CONV,label='NO')
plt.plot(t11,Data1t[1]/CONV,label='NO2')
plt.plot(t11,Data1t[2]/CONV,label='O3P')
plt.plot(t11,Data1t[3]/CONV,label='O3')
plt.xlabel("time[s]")
plt.ylabel("molar ratio[mol/mol]")
plt.title("Forward Method-NO,NO2,O3P,O3")
plt.legend()
plt.show()
"""
"""
#for O3P
plt.plot(t11,Data1t[2]/CONV,label='O3P')
plt.xlabel("time[s]")
plt.ylabel("molar ratio[mol/mol]")
plt.title("Forward Method-O3P")
plt.legend()
plt.show()
"""

###############backward method#################
"""
h2 = 2./100
r2 = int(1e+5)
t2 = np.arange(0,(r2+1)*h2,h2)
Data2 = np.zeros((r2+1,len(spec_name)))
Data2[0] = init
print(init)
for i in range(r2):
	Data2[i+1] = (Data2[i] + h2*Prod(Data2[i]))/(1.+h2*lamb(Data2[i]))
Data2t=np.transpose(Data2)
"""
"""
#for all species
for i in range(len(spec_name)):
       plt.plot(t2,Data2t[i],label=spec_name[i])
plt.xlabel("time[s]")
plt.ylabel("molar ratio[mol/mol]")
plt.title("Backward Method-all species")
plt.legend()
plt.show()
"""
"""
#for NO,NO2,O3P,O3
plt.plot(t2,Data2t[0],label='NO')
plt.plot(t2,Data2t[1],label='NO2')
plt.plot(t2,Data2t[2],label='O3P')
plt.plot(t2,Data2t[3],label='O3')
plt.xlabel("time[s]")
#plt.ylabel("molar ratio[mol/mol]")
plt.ylabel("number density [#/cm3]")
plt.title("Backward Method-NO,NO2,O3P,O3")
plt.legend()
plt.show()
"""
"""
#for O3P
plt.plot(t2,Data2t[2],label='O3P')
plt.xlabel("time[s]")
plt.ylabel("molar ratio[mol/mol]")
plt.title("Backward Method-O3P")
plt.legend()
plt.show()
"""

################QSSA method##################

h3 = 0.002
r3 = int(100000)
t3 = np.arange(0,(r3+1)*h3,h3)
Data3 = np.zeros((r3+1,len(spec_name)))
Data3[0] = init

for i in range(r3):
	for j in range(len(spec_name)):
		if h3*lamb(Data3[i])[j]<0.01:
			Data3[i+1][j] = Data3[i][j]+h3*(Prod(Data3[i])[j]-Loss(Data3[i])[j])
		elif h3*lamb(Data3[i])[j]>=0.01 and h3*lamb(Data3[i])[j]<=10.:
			Data3[i+1][j] = Data3[i][j]*np.exp(-1*h3*lamb(Data3[i])[j]) + Prod(Data3[i])[j]*(1-np.exp(-1*h3*lamb(Data3[i])[j]))/lamb(Data3[i])[j]
		else:
			Data3[i+1][j] = Prod(Data3[i])[j]/lamb(Data3[i])[j]

#Data3t=np.transpose(Data3/CONV)
Data3t=np.transpose(Data3)
#for all species
for i in range(len(spec_name)):
       plt.plot(t3,Data3t[i],label=spec_name[i])
plt.xlabel("time[s]")
plt.ylabel("number density [#/cm3]")
plt.title("QSSA Method-all species")
plt.legend()
plt.show()

#for NO,NO2,O3P,O3
plt.plot(t3,Data3t[0],label='NO')
plt.plot(t3,Data3t[1],label='NO2')
plt.plot(t3,Data3t[2],label='O3P')
plt.plot(t3,Data3t[3],label='O3')
plt.xlabel("time[s]")
#plt.ylabel("molar ratio[mol/mol]")
plt.ylabel("number density [#/cm3]")
plt.title("QSSA Method-NO,NO2,O3P,O3")
plt.legend()
plt.show()

#for O3P
plt.plot(t3,Data3t[2],label='O3P')
plt.xlabel("time[s]")
plt.ylabel("molar ratio[mol/mol]")
plt.title("QSSA Method-O3P")
plt.legend()
plt.show()

