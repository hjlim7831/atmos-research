import numpy as np
import matplotlib.pyplot as plt
import sys


#(a) Obtain the modified wavenumber for the 1st-order forward difference, 2nd-order central difference and fourth-order Pad'e scheme, respectively.
# Plot their real and imaginary parts separately and discuss your results.

k = 10.

def FD1(k,dx):
	return np.sin(k*dx)/dx, (1-np.cos(k*dx))/dx

def PD4(k,dx):
	return 3*np.sin(k*dx)/(2+np.cos(k*dx))/dx

l = 100
xx = np.array([np.pi*i/(k*l) for i in range(1,l+1)])

yy1, yy2, yy3, yy4 = FD1(k,xx)[0]*xx, FD1(k,xx)[1]*xx, PD4(k,xx)*xx, k*xx

plt.plot(yy4,yy1,label="FD1_Re & CD2")
plt.plot(yy4,yy2,label="FD1_Im")
plt.plot(yy4,yy3,label="PD4")
plt.plot(yy4,yy4,label="Exact")
plt.xlabel("k $\Delta$x")
plt.ylabel("k$^*\Delta$x")
plt.legend()
plt.savefig("./HW2-1a.png")
#plt.show()


#(b) use a uniform grid with N+1 points, where N=40, to numerically compute the first derivative of f.
# Plot the exact and numerical solutions using each scheme and discuss your results.

N = 40
tlen = 8
dx = tlen/N

XX = np.array([i*tlen/N for i in range(N+1)])

YY1 = FD1(k,dx)[0]*np.cos(10*XX)-FD1(k,dx)[1]*np.sin(10*XX)
YY2 = FD1(k,dx)[0]*np.cos(10*XX)
YY3 = PD4(k,dx)*np.cos(10*XX)
YY4 = 10.*np.cos(10*XX)

plt.figure(figsize=(12,3))
plt.plot(XX,YY1,'g',label="FD1")
plt.plot(XX,YY2,'b',label="CD2")
plt.plot(XX,YY3,'r',label="PD4")
plt.plot(XX,YY4,'k',label="exact")
plt.grid(which='major',axis='both')
plt.legend()
plt.savefig("./HW2-1b.png")
#plt.show()


#(c) Investigate the accuracy of each scheme at x=4 with varying the grid spacing h(=delta x) = 0.2, 0.1, 0.05, 0.025.

h = np.array([0.2,0.1,0.05,0.025])
tlen = 8

n = tlen/h
#print(n)

x = 4.

exac = 10.*np.cos(10*x)
ac1 = FD1(k,h)[0]*np.cos(10*x)-FD1(k,h)[1]*np.sin(10*x) - exac
ac2 = FD1(k,h)[0]*np.cos(10*x) - exac
ac3 = PD4(k,h)*np.cos(10*x) - exac

print("accuracy at x = 4 with h = 0.2, 0.1, 0.05, 0.025")
print("FD1:",ac1)
print("CD2:",ac2)
print("PD4:",ac3)








