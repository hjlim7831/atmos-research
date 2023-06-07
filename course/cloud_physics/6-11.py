import numpy as np
import matplotlib.pyplot as plt

M = 10**-16
ms = 132.14 #g/mol
T = 300. #K
a = 3.3*10**-5/T #cm
b = 4.3*2*M/ms

n = 2000
yst = 0.985
yed = 1.02

xx = np.array([i*10/(10**4*n) for i in range(1,n+1)])
yy = 1+a/xx - b/xx**3
yy1 = np.exp(a/xx)
yy2 = 1-b/xx**3

XX = xx*10**4
rst = (3*b/a)**0.5 *10**4
Sst = 1+(4*a**3/(27*b))**0.5


plt.plot(XX,yy,"k",linewidth=1)
plt.plot(XX,yy1,"k--",linewidth=1)
plt.plot(XX,yy2,"k--",linewidth=1)
plt.plot(XX,[1 for i in range(1,n+1)],"k",linewidth=1)
plt.plot([rst,rst],[0,Sst],"k-",linewidth=1)
plt.plot([0,rst],[Sst,Sst],"k-",linewidth=1)

plt.xlim(0.02,10)
plt.ylim(yst,yed)
plt.text(rst-0.01,yst-0.002,"r$^*$")
plt.text(0.016,Sst-0.0005,"S$^*$")
plt.text(0.2,0.997,r"$1- \frac{b}{r^3}$")
plt.text(0.12,1.01,"exp(a/r)")
plt.xlabel("Droplet Radius, $\mu$m")
plt.ylabel("Saturation ratio")
plt.xscale("log")
plt.xticks([1/10.,1.,10.,],['0.1','1','10'])
plt.yticks([0.99,1.00,1.01,1.02])

#plt.show()
plt.savefig("HW6-11.png")





