import numpy as np
import matplotlib.pyplot as plt
import sys

#advection equation 0<=x<=1
#assumption: fluid is moving with constant velocity, c
#Boundary Condition: Periodic
#Plot the numerical and exact solutions for t=5

tlen, dx, c = 5, 1/36, 0.2
nx = int(1/dx)

courn = np.array([0.1,0.5,0.9])
DT = courn*dx/c
t = tlen/DT


def phi(x,t):
	if (13/18+c*t)%1<=x<=(17/18+c*t)%1:
		return 9**4*(((x-c*t)%1-5/6)**2-1/81)**2
	else:
		return 0

phi5 = np.zeros(nx)

for i in range(nx):
	phi5[i] = phi(i*dx,5)

lt = len(courn)
ht, wd = 6, 8
cl = ['tab:blue','tab:orange','tab:green','tab:red']

delt, sola5, solb5, solc5 = np.zeros(lt), np.zeros((lt,nx)), np.zeros((lt,nx)), np.zeros((lt,nx))

for i in range(lt):
	wlt = int(t[i])
	tt = np.array([DT[i]*j for j in range(wlt+1)])
	dt = DT[i]
	nt = wlt+1
	mesh1 = np.full((nt,nx),np.nan)
	mesh2 = np.full((nt,nx),np.nan)
	mesh3 = np.full((nt,nx),np.nan)
	for j in range(nx): #for initial condition
		if 13/18<=j*dx<=17/18:
			mesh1[0,j] = 9**4*((j*dx-5/6)**2-1/81)**2
			mesh2[0,j] = 9**4*((j*dx-5/6)**2-1/81)**2
			mesh3[0,j] = 9**4*((j*dx-5/6)**2-1/81)**2
		else:
			mesh1[0,j], mesh2[0,j], mesh3[0,j] = 0., 0., 0.
	##Calculate Numerical Solution
	n = 0#(first time step)
	for j in range(nx):
		jjm2, jjm1, jj, jj1, jj2 = (j-2)%nx, (j-1)%nx, j%nx, (j+1)%nx, (j+2)%nx
		mesh1[n+1,jj] = -(c*dt)**2/(8*dx**2)*(2*mesh1[n,jj]-mesh1[n,jj2]-mesh1[n,jjm2])-c*dt/(2*dx)*(mesh1[n,jj1]-mesh1[n,jjm1])+mesh1[n,jj]
		mesh2[n+1,jj] = -c*dt/dx*(mesh2[n,jj]-mesh2[n,jjm1])+mesh2[n,jj]
		mesh3[n+1,jj] = -c*dt/(2*dx)*(mesh3[n,jj1]-mesh3[n,jjm1])+(c*dt/dx)**2/2*(mesh3[n,jj1]-2*mesh3[n,jj]+mesh3[n,jjm1])+mesh3[n,jj]
	## when n>=1
	for n in range(1,nt-1):
		for j in range(nx):
			jjm2, jjm1, jj, jj1, jj2 = (j-2)%nx, (j-1)%nx, j%nx, (j+1)%nx, (j+2)%nx
			mesh1[n+1,jj] = -c*dt/dx*(mesh1[n,jj1]-mesh1[n,jjm1])+mesh1[n-1,jj]
			mesh2[n+1,jj] = -c*dt/dx*(mesh2[n,jj]-mesh2[n,jjm1])+mesh2[n,jj]
			mesh3[n+1,jj] = -c*dt/(2*dx)*(mesh3[n,jj1]-mesh3[n,jjm1])+(c*dt/dx)**2/2*(mesh3[n,jj1]-2*mesh3[n,jj]+mesh3[n,jjm1])+mesh3[n,jj]

	sola5[i,:] = mesh1[nt-1,:]
	solb5[i,:] = mesh2[nt-1,:]
	solc5[i,:] = mesh3[nt-1,:]

x = np.array([i*dx for i in range(nx)])

fig, axes = plt.subplots(3)
fig.set_figheight(ht)
fig.set_figwidth(wd)


for i in range(3):
	axes[i].plot(x,sola5[i,:],label="LF-C")
	axes[i].plot(x,solb5[i,:],label="F-U")
	axes[i].plot(x,solc5[i,:],label="F-LW")
	axes[i].plot(x,phi5,color="k",label="exact")
	axes[i].set_title("$\mu$="+str(courn[i]))
	axes[i].set_ylim(-0.6,1.6)

plt.tight_layout()
plt.legend()
plt.savefig("final_4.png")
plt.show()







