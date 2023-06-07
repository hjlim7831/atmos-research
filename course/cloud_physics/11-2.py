import numpy as np
import matplotlib.pyplot as plt

N0 = 0.08*1e-4 #mm-4
k = 4*3600*1e+3 #h-1
K = 1420/10**0.5**3600 #mm 0.5 /h
A = 965*10*3600 #mm/h
B = 1030*10*3600 #mm/h
C = 0.6 #mm-1

n = 1000

Z = np.array([i+1 for i in range(n)])

R1 = (Z/180)**(1/1.56)

b = (720*N0/(Z*1e-9))**(1/7)
R2 = np.pi*N0*(A/b**4-B/(C+b)**4)
R = (Z/200)**(1/1.6)


plt.plot(R1,Z,label="11-2(a)")
plt.plot(R2,Z,label="11-2(b)")
plt.plot(R,Z,label="M-P")
plt.xlabel("R (mm/h)")
plt.ylabel("Z ($mm^6/m^3$)")
plt.xscale("log")
plt.legend()
plt.savefig("./HW11-2.png")
plt.show()








