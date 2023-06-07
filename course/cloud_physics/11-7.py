import numpy as np
import matplotlib.pyplot as plt
import sys

diamf = [0.,0.1,0.2,0.3,0.4,0.5,0.6,0.7,0.8,0.9,1.0,1.2,1.4,1.6,1.8,2.0,2.2,2.4,\
	        2.6,2.8,3.0,3.2,3.4,3.6,3.8,4.0,4.2,4.4,4.6,4.8,5.0,5.2,5.4,5.6,5.8]  # mm
fs = [0.,0.27,0.72,1.17,1.62,2.06,2.47,2.87,3.27,3.67,4.03,4.64,5.17,5.65,6.09,6.49,6.90,7.27,\
	        7.57,7.82,8.06,8.26,8.44,8.60,8.72,8.83,8.92,8.98,9.03,9.07,9.09,9.12,9.14,9.16,9.17] # m/s

diami = [0.3,0.4,0.5,0.6,0.7,0.8,1.0,1.2,1.4,1.6,1.8,2.1,2.4] #Diameter interval, mm
numdrop = np.array([45,39,55,75,84,195,129,53,13,4,3,1])# numer of drops

ld = len(diami)
diamF = list((np.array(diami[0:ld-1])+np.array(diami[1:ld]))/2)
print(diamF)

sampA = 50*1e+2 #mm2
per = 1/60 #hr

def u(D): #D: mm
    l = len(diamf)
    for i in range(l-1):
        if diamf[i]<= D< diamf[i+1]:
            sl = (fs[i+1]-fs[i])/(diamf[i+1]-diamf[i])
            y = sl*(D-diamf[i])+fs[i]
            return y*1e+3*3600 #mm/hr
            break

R1 = 0.
R = 0.
Z = 0.
for i in range(ld-1):
	R += np.pi/6*diamF[i]**3/(sampA*per)*numdrop[i] #mm/hr
	R1 += np.pi/6*numdrop[i]*u(diamF[i])*diamF[i]**3

A  = R/R1 #mm-3
print("A(mm-3):",A)

for i in range(ld-1):
	Z += A*numdrop[i]*diamF[i]**6*10**9 #mm6/m3


print("R(mm/h):",R)
print("Z(mm6/m3):",Z)
print(10*np.log10(Z),"dBz")










