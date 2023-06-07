import numpy as np
import matplotlib.pyplot as plt

U = 10	 	#m/s
N = 0.01 	#s-1
a = 10*1e+3	#m
hm = 300 	#m
l = N/U
k = 1/a
print("l:",l,"m-1")
print("k:",k,"m-1")
rho0 = 1.225 #kg/m3
#l>>k case
#(1)a. Plot w', u', pi', b' (on xz plane)

def wp(X,Z):#m/s
	x, z = 1e+3*X, 1e+3*Z
	return U*hm*a*(-2*a*x*np.cos(l*z)+(x**2-a**2)*np.sin(l*z))/(x**2+a**2)**2

def up(X,Z):#m/s
	x, z = 1e+3*X, 1e+3*Z
	return U*l*hm*a*(a*np.sin(l*z)+x*np.cos(l*z))/(x**2+a**2)

def pip(X,Z):#m2/s2
	x, z = 1e+3*X, 1e+3*Z
	return -U**2*l*hm*a*(a*np.sin(l*z)+x*np.cos(l*z))/(x**2+a**2)

def bp(X,Z): #m/s2
	x, z = 1e+3*X, 1e+3*Z
	return N**2*hm*a*(-a*np.cos(l*z)+x*np.sin(l*z))/(x**2+a**2)

Xmesh, Zmesh = np.meshgrid(np.linspace(-40,40,1000),np.linspace(0,10,1000))

lw = 0.8

Wp = wp(Xmesh,Zmesh)
Up = up(Xmesh,Zmesh)
Pip = pip(Xmesh,Zmesh)
Bp = bp(Xmesh,Zmesh)

fig, axes = plt.subplots(2,2)
fig.set_figheight(6)
fig.set_figwidth(8)

axes[0,0].set_title("w'")
axes[0,0].set_xlabel("x(km)")
axes[0,0].set_ylabel("z(km)")
axes[0,1].set_title("u'")
axes[0,1].set_xlabel("x(km)")
axes[0,1].set_ylabel("z(km)")
axes[1,0].set_title("$\pi$'")
axes[1,0].set_xlabel("x(km)")
axes[1,0].set_ylabel("z(km)")
axes[1,1].set_title("b'")
axes[1,1].set_xlabel("x(km)")
axes[1,1].set_ylabel("z(km)")


cs1 = axes[0,0].contourf(Xmesh,Zmesh,Wp)
cs2 = axes[0,1].contourf(Xmesh,Zmesh,Up)
cs3 = axes[1,0].contourf(Xmesh,Zmesh,Pip)
cs4 = axes[1,1].contourf(Xmesh,Zmesh,Bp)

fig.colorbar(cs1,ax=axes[0,0],label="($m/s$)")
fig.colorbar(cs2,ax=axes[0,1],label="($m/s$)")
fig.colorbar(cs3,ax=axes[1,0],label="($m^2/s^2$)")
fig.colorbar(cs4,ax=axes[1,1],label="($m/s^2$)")

plt.tight_layout()
plt.savefig("./HW17-1a.png")
plt.show()

#(1)b. Plot the vertical Profiles of M, E using numerical(trapezoidal rule) method
M = np.zeros(1000)
E = np.zeros(1000)
for i in range(1000-1):
	M += 1e+3*(Xmesh[0,i+1]-Xmesh[0,i])*(Up[:,i+1]*Wp[:,i+1]+Up[:,i]*Wp[:,i])/2
	E += 1e+3*(Xmesh[0,i+1]-Xmesh[0,i])*rho0*(Pip[:,i+1]*Wp[:,i+1]+Pip[:,i]*Wp[:,i])/2
	
fig, axes = plt.subplots(1,2)
fig.set_figheight(4)
fig.set_figwidth(8)

axes[0].plot(M,Zmesh[:,0])
axes[0].set_title("M")
axes[0].set_xlabel("M($m^3/s^2$)")
axes[0].set_ylabel("z(km)")
axes[1].plot(E,Zmesh[:,0])
axes[1].set_title("E")
axes[1].set_xlabel("E($kg/s^3$)")
axes[1].set_ylabel("z(km)")
plt.tight_layout()
plt.savefig("./HW17-b.png")
plt.show()

#(1)c. Calculate mountain drag(D) Numerically.

def Dn(X):
	x = 1e+3*X
	return 2*rho0*U**2*hm**2*l*a**3*x**2/(x**2+a**2)**3
D = 0.
for i in range(1000-1):
	D += 1e+3*(Xmesh[0,i+1]-Xmesh[0,i])*(Dn(Xmesh[0,i+1])+Dn(Xmesh[0,i]))/2

Da = np.pi/4*rho0*U*N*hm**2

print("Numerical D:",D,"(N/m)")
print("Analytical D:",Da,"(N/m)")


#(2) Calculate D at z=0
D2 = 0.
for i in range(1000-1):
	D2 += -rho0*1e+3*(Xmesh[0,i+1]-Xmesh[0,i])*(wp(Xmesh[0,i+1],0)*up(Xmesh[0,i+1],0)+wp(Xmesh[0,i],0)*up(Xmesh[0,i],0))/2

print("Numerical D2:",D2,"(N/m)")









