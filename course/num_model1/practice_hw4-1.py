import numpy as np
import matplotlib.pyplot as plt

#advection equation 0<=x<=1
#assumption: fluid is moving with constant velocity, c
#Boundary Condition: phi(0,t) = 1, phi(1,t) = -1
#Plot the numerical and exact solutions for t=0,4,8.

#Use 41 points in the x direction and use different values of delt.

nx = 41
tlen, xlen = 8, 1
dx = xlen/(nx-1)

c = 0.1
def phi(x,t):
	if 0<=x<=c*t:
		return 1
	elif c*t<=x<=c*t+0.1:
		return np.cos(10*np.pi*(x-c*t))
	elif c*t+0.1 <=x<=1:
		return -1
	else:
		print("x is out of range(0,1)")

phi0, phi4, phi8 = np.zeros(nx), np.zeros(nx), np.zeros(nx)

for i in range(nx):
	phi0[i] = phi(i*dx,0)
	phi4[i] = phi(i*dx,4)
	phi8[i] = phi(i*dx,8)


#t = np.array([10, 20, 40]) #set dt
#t = np.array([40, 80, 160]) #set dt
t = np.array([16, 20, 32, 40])
lt = len(t)
ht, wd = 6, 8
cl = ['tab:blue','tab:orange','tab:green','tab:red']

delt, sola0, sola4, sola8 = np.zeros(lt), np.zeros((lt,nx)), np.zeros((lt,nx)), np.zeros((lt,nx))
solb0, solb4, solb8 = np.zeros((lt,nx)), np.zeros((lt,nx)), np.zeros((lt,nx))
solc0, solc4, solc8 = np.zeros((lt,nx)), np.zeros((lt,nx)), np.zeros((lt,nx))

for i in range(lt):
	wlt = t[i]
	tt = np.array([tlen/(wlt*2)*j for j in range(wlt*2+1)])
	dt = tlen/(wlt*2)
	nt = wlt*2+1
	mesh1 = np.full((nt,nx),np.nan)
	mesh2 = np.full((nt,nx),np.nan)
	mesh3 = np.full((nt,nx),np.nan)
	mesh1[:,0], mesh1[:,nx-1] = 1., -1.
	mesh2[:,0], mesh2[:,nx-1] = 1., -1.
	mesh3[:,0], mesh3[:,nx-1] = 1., -1.
	for j in range(nx): #for initial condition
		if j*dx<=0.1:
			mesh1[0,j] = np.cos(10*np.pi*dx*j)
			mesh2[0,j] = np.cos(10*np.pi*dx*j)
			mesh3[0,j] = np.cos(10*np.pi*dx*j)
		elif 0.1<=j*dx<=1:
			mesh1[0,j], mesh2[0,j], mesh3[0,j] = -1, -1, -1
	##Calculate Numerical Solution
	n = 0#(first time step)
	for j in range(nx-2):
		mesh1[n+1,j+1] = -c*dt/(2*dx)*(mesh1[n,j+2]-mesh1[n,j])+mesh1[n,j+1]
		mesh3[1,j+1] = -c*dt/(2*dx)*(mesh3[0,j+2]-mesh3[0,j])+mesh3[0,j+1]
	for j in range(nx-1):
		mesh2[n+1,j+1] = -c*dt/dx*(mesh2[n,j+1]-mesh2[n,j])+mesh2[n,j+1]
	for n in range(1,nt-1):
		for j in range(nx-2):
			mesh1[n+1,j+1] = -c*dt/(2*dx)*(mesh1[n,j+2]-mesh1[n,j])+mesh1[n,j+1]
			mesh3[n+1,j+1] = -c*dt/dx*(mesh3[n,j+2]-mesh3[n,j])+mesh3[n-1,j+1]
		for j in range(nx-1):
			mesh2[n+1,j+1] = -c*dt/dx*(mesh2[n,j+1]-mesh2[n,j])+mesh2[n,j+1]

	sola0[i,:] = mesh1[0,:]
	sola4[i,:] = mesh1[wlt,:]
	sola8[i,:] = mesh1[nt-1,:]
	solb0[i,:] = mesh2[0,:]
	solb4[i,:] = mesh2[wlt,:]
	solb8[i,:] = mesh2[nt-1,:]
	solc0[i,:] = mesh3[0,:]
	solc4[i,:] = mesh3[wlt,:]
	solc8[i,:] = mesh3[nt-1,:]
	delt[i] = dt

x = np.array([i*dx for i in range(nx)])

#(a) Forward Euler time scheme & second order central difference

fig, axes = plt.subplots(3)
fig.set_figheight(ht)
fig.set_figwidth(wd)


for i in range(lt):
	axes[0].plot(x,sola0[i,:],label="$\Delta t$="+str(delt[i]))
	axes[1].plot(x,sola4[i,:],label="$\Delta t$="+str(delt[i]))
	axes[2].plot(x,sola8[i,:],label="$\Delta t$="+str(delt[i]))


axes[0].plot(x,phi0,color="k",label="exact")
axes[1].plot(x,phi4,color="k",label="exact")
axes[2].plot(x,phi8,color="k",label="exact")
axes[0].set_title("t = 0")
axes[1].set_title("t = 4")
axes[2].set_title("t = 8")
plt.tight_layout()
plt.legend()
plt.savefig("HW4-1a.png")
plt.show()

#(b) Forward Euler time scheme & first order upwind difference

fig, axes = plt.subplots(3)
fig.set_figheight(ht)
fig.set_figwidth(wd)


for i in range(lt):
    axes[0].plot(x,solb0[i,:],label="$\Delta t$="+str(delt[i]))
    axes[1].plot(x,solb4[i,:],label="$\Delta t$="+str(delt[i]))
    axes[2].plot(x,solb8[i,:],label="$\Delta t$="+str(delt[i]))


axes[0].plot(x,phi0,color="k",label="exact")
axes[1].plot(x,phi4,color="k",label="exact")
axes[2].plot(x,phi8,color="k",label="exact")
axes[0].set_title("t = 0")
axes[1].set_title("t = 4")
axes[2].set_title("t = 8")
plt.tight_layout()
plt.legend()
plt.savefig("HW4-1b.png")
plt.show()


#(c) Leapfrog time scheme & second order central difference

fig, axes = plt.subplots(3)
fig.set_figheight(ht)
fig.set_figwidth(wd)


for i in range(lt):
    axes[0].plot(x,solc0[i,:],label="$\Delta t$="+str(delt[i]))
    axes[1].plot(x,solc4[i,:],label="$\Delta t$="+str(delt[i]))
    axes[2].plot(x,solc8[i,:],label="$\Delta t$="+str(delt[i]))


axes[0].plot(x,phi0,color="k",label="exact")
axes[1].plot(x,phi4,color="k",label="exact")
axes[2].plot(x,phi8,color="k",label="exact")
axes[0].set_title("t = 0")
axes[1].set_title("t = 4")
axes[2].set_title("t = 8")
plt.tight_layout()
plt.legend()
plt.savefig("HW4-1c.png")
plt.show()






