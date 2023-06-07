import numpy as np
import matplotlib.pyplot as plt
import sys

Xmesh, Zmesh = np.meshgrid(np.linspace(-150000,150000,10000+1),np.linspace(0,3000,1000+1))
XX = Xmesh[0,:]
ZZ = Zmesh[:,0]
lx = len(Xmesh[0,:])
lz = len(Xmesh[:,0])

g = 9.8 #m/s2
cp = 1005. #J/kg/K
N = 0.01 #s-1
q0 = 0.1 #J/s
U0 = 3 #m/s
x1 = 10*1e+3 #m
x2 = 5*x1 #m
h = 1*1e+3 #m
T0 = 15+273.15 #K
U1 = 6 #m/s
s = 1e-3 #s-1
a = ((N**2/s**2)-1/4)**0.5
E = 1/(2*a*s*h)*(U0+s*h)**0.5
alpha = a*np.log(U0+s*h)
beta = a*np.log(U0)
F = g*q0*x1/(cp*T0*N**2)

def G(x):
	return x1/(x**2+x1**2)-x2/(x**2+x2**2)

def H(x):
	return x/(x**2+x1**2)-x/(x**2+x2**2)

def Gb(x):
	return np.arctan(x/x1)-np.arctan(x/x2)

def Hb(x):
	return 1/2*np.log((x**2+x1**2)/(x**2+x2**2))
def wp(XX,ZZ):
	lz, lx = len(ZZ[:,0]), len(XX[0,:])
	x = XX[0,:]
	RE = np.zeros((lz,lx))
	for k in range(lz):
		z = ZZ[k,0]
		y = a*np.log(U0+s*z)
		if z>h:
			f = np.sin(y)*(np.cos(alpha-2*beta)-np.cos(alpha))+np.cos(y)*(np.sin(alpha-2*beta)+np.sin(alpha))
			g = np.sin(y)*(np.sin(alpha-2*beta)+np.sin(alpha))+np.cos(y)*(np.cos(alpha)-np.cos(alpha-2*beta))
			RE[k,:] = F*(U0+s*z)**0.5*(G(x)*(E*f-U0**(-0.5)*np.cos(y-beta))-H(x)*(E*g-U0**(-0.5)*np.sin(y-beta)))
		else:
			f = np.sin(alpha)*(np.cos(y-2*beta)-np.cos(y))+np.cos(alpha)*(np.sin(y)+np.sin(y-2*beta))
			g = np.cos(alpha)*(np.cos(y-beta)-np.cos(y))-np.sin(alpha)*(np.sin(y-2*beta)+np.sin(y))
			RE[k,:] = F*(U0+s*z)**0.5*(G(x)*(E*f+(1-z/h)*(U0+s*z)**(-0.5)-U0**(-0.5)*np.cos(y-beta))+H(x)*(E*g+U0**(-0.5)*np.sin(y-beta)))
	return RE
			
def up(XX,ZZ):
	lz, lx = len(ZZ[:,0]), len(XX[0,:])
	x = XX[0,:] 
	RE = np.zeros((lz,lx))
	for k in range(lz):
		z = ZZ[k,0]
		y = a*np.log(U0+s*z)
		if z>h:
			f = np.sin(y)*(np.cos(alpha-2*beta)-np.cos(alpha))+np.cos(y)*(np.sin(alpha-2*beta)+np.sin(alpha))
			fp = np.cos(y)*(np.cos(alpha-2*beta)-np.cos(alpha))-np.sin(y)*(np.sin(alpha-2*beta)+np.sin(alpha))
			g = np.sin(y)*(np.sin(alpha-2*beta)+np.sin(alpha))+np.cos(y)*(np.cos(alpha)-np.cos(alpha-2*beta))
			gp = np.cos(y)*(np.sin(alpha-2*beta)+np.sin(alpha))-np.sin(y)*(np.cos(alpha)-np.cos(alpha-2*beta))
			RE[k,:] = -F*s/2*(U0+s*z)**(-0.5)*(Gb(x)*(E*f-U0**(-0.5)*np.cos(y-beta))-Hb(x)*(E*g-U0**(-0.5)*np.sin(y-beta)))\
					-F*(U0+s*z)**0.5*(Gb(x)*(E*fp+U0**(-0.5)*np.sin(y-beta))-Hb(x)*(E*gp-U0**(-0.5)*np.cos(y-beta)))*a*s/(U0+s*z)
		else:
			f = np.sin(alpha)*(np.cos(y-2*beta)-np.cos(y))+np.cos(alpha)*(np.sin(y)+np.sin(y-2*beta))
			fp = np.sin(alpha)*(-np.sin(y-2*beta)+np.sin(y))+np.cos(alpha)*(np.cos(y)+np.cos(y-2*beta))
			g = np.cos(alpha)*(-np.cos(y-2*beta)+np.cos(y))+np.sin(alpha)*(np.sin(y-2*beta)+np.sin(y))
			gp = np.cos(alpha)*(np.sin(y-2*beta)-np.sin(y))+np.sin(alpha)*(np.cos(y-2*beta)+np.cos(y))
			dydz = a*s/(U0+s*z)
			RE[k,:] = -F*s/2*(U0+s*z)**(-0.5)*(Gb(x)*(E*f+(1-z/h)*(U0+s*z)**(-0.5)-U0**(-0.5)*np.cos(y-beta))-Hb(x)*(E*g-U0**(-0.5)*np.sin(y-beta)))\
					-F*(U0+s*z)**0.5*(Gb(x)*(E*fp*dydz+(-1/h*(U0+s*z)**(-0.5)+(1-z/h)*(U0+s*z)**(-1.5)*(-s/2)+U0**(-0.5)*np.sin(y-beta)*dydz))-Hb(x)*dydz*(E*gp-U0**(-0.5)*np.cos(y-beta)))
	return RE


lw = 0.8

Wp = wp(Xmesh,Zmesh)
print(Wp)
Up = up(Xmesh,Zmesh)

M = np.zeros(lz)
dx = XX[1]-XX[0]
print(dx)

for i in range(lx-1):
	M += dx*(Up[:,i+1]*Wp[:,i+1]+Up[:,i]*Wp[:,i])/2


fig, axes = plt.subplots(2,1)
fig.set_figheight(6)
fig.set_figwidth(8)

axes[0].set_title("w'")
axes[0].set_xlabel("x(m)")
axes[0].set_ylabel("z(m)")
axes[1].set_title("u'")
axes[1].set_xlabel("x(m)")
axes[1].set_ylabel("z(m)")

#print(Zmesh)
cs1 = axes[0].contourf(Xmesh,Zmesh,Wp)
cs2 = axes[1].contourf(Xmesh,Zmesh,Up)

fig.colorbar(cs1,ax=axes[0],label="($m/s$)")
fig.colorbar(cs2,ax=axes[1],label="($m/s$)")

plt.tight_layout()
plt.savefig("./HW18-1a.png")
plt.show()

plt.plot(M,ZZ)
plt.savefig("./HW18-1b.png")
plt.show()



