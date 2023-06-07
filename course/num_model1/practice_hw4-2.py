import numpy as np
import matplotlib.pyplot as plt
import sys

#advection equation 0<=x<=1, 0<=y<=1
#assumption: fluid is moving with constant velocity, cx=0.1, cy=0.1
#Boundary Condition: Periodic boundary
#Plot the numerical and exact solutions for t=0,10.

#Use 101 points in the x direction and use different values of delt.

nx, ny = 101, 101
tlen, xlen, ylen = 10, 1, 1
dx, dy = xlen/(nx-1), ylen/(ny-1)
Xmesh, Ymesh = np.meshgrid(np.linspace(0,1,nx),np.linspace(0,1,ny))
cx, cy = 0.1, 0.1

#t = np.array([20, 40, 80]) #set dt
#t = np.array([200, 500, 1000])
t = np.array([500,1000,2000])
lt = len(t)
ht, wd = 4, 8
cl = ['tab:blue','tab:orange','tab:green','tab:red']

delt, sola0, sola10 = np.zeros(lt), np.zeros((lt,nx,ny)), np.zeros((lt,nx,ny))
solb0, solb10 = np.zeros((lt,nx,ny)), np.zeros((lt,nx,ny))
solc0, solc10 = np.zeros((lt,nx,ny)), np.zeros((lt,nx,ny))

for i in range(lt):
	wlt = t[i]
	tt = np.array([tlen/(wlt)*j for j in range(wlt+1)])
	dt = tlen/(wlt)
	nt = wlt+1
	mesh1 = np.full((nt,nx,ny),np.nan)
	mesh2 = np.full((nt,nx,ny),np.nan)
	mesh3 = np.full((nt,nx,ny),np.nan)
	for j in range(nx): #for initial condition
		for k in range(ny):
			if 0.3<=j*dx<=0.7 and 0.3<=k*dy<=0.7:
				mesh1[0,j,k], mesh2[0,j,k], mesh3[0,j,k] = 1., 1., 1.
			else:
				mesh1[0,j,k], mesh2[0,j,k], mesh3[0,j,k] = 0., 0., 0.
	##Calculate Numerical Solution
	n = 0#(first time step)
	for j in range(nx):
		for k in range(ny):
			mesh1[n+1,j%nx,k%ny] = -cx*dt/(2*dx)*(mesh1[n,(j+1)%nx,k%ny]-mesh1[n,(j-1)%nx,k%ny])-cy*dt/(2*dy)*(mesh1[n,j%nx,(k+1)%ny]-mesh1[n,j%nx,(k-1)%ny])+mesh1[n,j%nx,k%ny]
			mesh3[n+1,j%nx,k%ny] = -cx*dt/(2*dx)*(mesh3[n,(j+1)%nx,k%ny]-mesh3[n,(j-1)%nx,k%ny])-cy*dt/(2*dy)*(mesh3[n,j%nx,(k+1)%ny]-mesh3[n,j%nx,(k-1)%ny])+mesh3[n,j%nx,k%ny]
			mesh2[n+1,j%nx,k%ny] = -cx*dt/dx*(mesh2[n,j%nx,k%ny]-mesh2[n,(j-1)%nx,k%ny])-cy*dt/dy*(mesh2[n,j%nx,k%ny]-mesh2[n,j%nx,(k-1)%ny])+mesh2[n,j%nx,k%ny]
	for n in range(1,nt-1): # time step(2 ~)
		for j in range(nx):
			for k in range(ny):
				mesh1[n+1,j%nx,k%ny] = -cx*dt/(2*dx)*(mesh1[n,(j+1)%nx,k%ny]-mesh1[n,(j-1)%nx,k%ny])-cy*dt/(2*dy)*(mesh1[n,j%nx,(k+1)%ny]-mesh1[n,j%nx,(k-1)%ny])+mesh1[n,j%nx,k%ny]
				mesh3[n+1,j%nx,k%ny] = -cx*dt/dx*(mesh3[n,(j+1)%nx,k%ny]-mesh3[n,(j-1)%nx,k%ny])-cy*dt/dy*(mesh3[n,j%nx,(k+1)%ny]-mesh3[n,j%nx,(k-1)%ny])+mesh3[n-1,j%nx,k%ny]
				mesh2[n+1,j%nx,k%ny] = -cx*dt/dx*(mesh2[n,j%nx,k%ny]-mesh2[n,(j-1)%nx,k%ny])-cy*dt/dy*(mesh2[n,j%nx,k%ny]-mesh2[n,j%nx,(k-1)%ny])+mesh2[n,j%nx,k%ny]

	sola0[i,:,:] = mesh1[0,:,:]
	sola10[i,:,:] = mesh1[nt-1,:,:]
	solb0[i,:,:] = mesh2[0,:,:]
	solb10[i,:,:] = mesh2[nt-1,:,:]
	solc0[i,:,:] = mesh3[0,:,:]
	solc10[i,:,:] = mesh3[nt-1,:,:]
	delt[i] = dt

x = np.array([i*dx for i in range(nx)])

#(a) Forward Euler time scheme & second order central difference

fig, axes = plt.subplots(2,lt)
fig.set_figheight(ht)
fig.set_figwidth(wd)


for i in range(lt):
	cs1 = axes[0,i].contourf(Xmesh,Ymesh,sola0[i,:,:])
	cs2 = axes[1,i].contourf(Xmesh,Ymesh,sola10[i,:,:])
	fig.colorbar(cs1,ax=axes[0,i])
	fig.colorbar(cs2,ax=axes[1,i])
	axes[0,i].set_title("$\Delta t$="+str(delt[i]))


axes[0,0].set_ylabel("t = 0")
axes[1,0].set_ylabel("t = 10")
plt.tight_layout()
plt.savefig("./HW4-2d.png")
plt.show()

#(b) Forward Euler time scheme & first order upwind difference

fig, axes = plt.subplots(2,lt)
fig.set_figheight(ht)
fig.set_figwidth(wd)


for i in range(lt):
    cs1 = axes[0,i].contourf(Xmesh,Ymesh,solb0[i,:,:])
    cs2 = axes[1,i].contourf(Xmesh,Ymesh,solb10[i,:,:])
    fig.colorbar(cs1,ax=axes[0,i])
    fig.colorbar(cs2,ax=axes[1,i])
    axes[0,i].set_title("$\Delta t$="+str(delt[i]))


axes[0,0].set_ylabel("t = 0")
axes[1,0].set_ylabel("t = 10")
plt.tight_layout()
plt.savefig("./HW4-2e.png")
plt.show()


#(c) Leapfrog time scheme & second order central difference

fig, axes = plt.subplots(2,lt)
fig.set_figheight(ht)
fig.set_figwidth(wd)


for i in range(lt):
    cs1 = axes[0,i].contourf(Xmesh,Ymesh,solc0[i,:,:])
    cs2 = axes[1,i].contourf(Xmesh,Ymesh,solc10[i,:,:])
    fig.colorbar(cs1,ax=axes[0,i])
    fig.colorbar(cs2,ax=axes[1,i])
    axes[0,i].set_title("$\Delta t$="+str(delt[i]))


axes[0,0].set_ylabel("t = 0")
axes[1,0].set_ylabel("t = 10")
plt.tight_layout()
plt.savefig("./HW4-2f.png")
plt.show()





