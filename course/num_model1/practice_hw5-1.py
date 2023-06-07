import numpy as np
import matplotlib.pyplot as plt


# d^2p/dx^2 + d^2p/dy^2 = 6xy(1-y) -2x^3, 0<=x<=1, 0<=y<=1
# Boundary Condition: p(0,y) = 0, p(1,y) = y(1-y), p(x,0) = 0, p(x,1) = 0 (Dirichlet boundary conditon)
# analytic solution: pe(x,y) = y(1-y)x^3

#(a) Solve the Poisson equation to get a numerical solution pc(x,y)

#(b) Evaluate error[pc(x,y) - pe(x,y)]
# [plot error map]


def pe(x,y):
	return y*(1-y)*x**3

#change variables
nx = np.array([6,11,21,26])
ht, wd = 4, 11 # Figure height & width
eps = 5e-5
beta = 1.9

#======================
ny = nx
nk = int(1e+3)
xlen, ylen = 1, 1
lx = len(nx)
nn1, nn2, nn3 = np.zeros(lx), np.zeros(lx), np.zeros(lx)

fig, axes = plt.subplots(2,lx+1)
fig.set_figheight(ht)
fig.set_figwidth(wd)

#Jacobi
for ii in range(lx):
	pnx, pny = int(nx[ii]), int(ny[ii])
	dx, dy = xlen/(pnx-1), ylen/(pny-1) #put this in do loop!
	XX, YY = np.meshgrid(np.linspace(0,1,pnx),np.linspace(0,1,pny))
	solJ = np.full((nk,pnx,pny),np.nan)
	PE = np.full((pnx,pny),np.nan)
	solJ[0,:,:], solJ[0,:,:], solJ[0,:,:] = 0., 0., 0.
	solJ[:,0,:], solJ[:,:,0], solJ[:,:,pny-1] = 0., 0., 0.
	for j in range(pny):
		solJ[:,pnx-1,j] = j*dy*(1-j*dy)
		for i in range(pnx):
			x, y = i*dx, j*dy
			PE[i,j] = pe(x,y)
	for k in range(nk-1):
		for i in range(1,pnx-1):
			for j in range(1,pny-1):
				x, y = dx*i, dy*j
				solJ[k+1,i,j] = 1/4*(solJ[k,i+1,j]+solJ[k,i-1,j]+solJ[k,i,j+1]+solJ[k,i,j-1]-dx**2*(6*x*y*(1-y)-2*x**3))
		R2 = (np.sum((solJ[k,:,:] - solJ[k-1,:,:])**2)/(pnx*pny))**0.5
#		print(R2)
		if R2<eps:
			nn = k-1
			nn1[ii] = nn
			break
	cs1 = axes[0,ii].contourf(XX,YY,solJ[nn,:,:],levels=[-0.04+0.04*i for i in range(9)])
	cs2 = axes[1,ii].contourf(XX,YY,solJ[nn,:,:]-PE)
	fig.colorbar(cs1,ax=axes[0,ii])
	fig.colorbar(cs2,ax=axes[1,ii])
	axes[0,ii].set_title("$\Delta x$="+str(dx))
	axes[1,ii].set_title("anomaly")
print(nn1)

cs3 = axes[0,lx].contourf(XX,YY,PE,levels=[-0.04+0.04*i for i in range(9)])
fig.colorbar(cs3,ax=axes[0,lx])
axes[1,lx].axis('off')
axes[0,lx].set_title("exact")
plt.tight_layout()
plt.savefig("./HW5-1_1.png")
plt.show()

#Gauss-Seidel
fig, axes = plt.subplots(2,lx+1)
fig.set_figheight(ht)
fig.set_figwidth(wd)

for ii in range(lx):
    pnx, pny = int(nx[ii]), int(ny[ii])
    dx, dy = xlen/(pnx-1), ylen/(pny-1) #put this in do loop!
    XX, YY = np.meshgrid(np.linspace(0,1,pnx),np.linspace(0,1,pny))
    solG = np.full((nk,pnx,pny),np.nan)
    PE = np.full((pnx,pny),np.nan)
    solG[0,:,:], solG[0,:,:], solG[0,:,:] = 0., 0., 0.
    solG[:,0,:], solG[:,:,0], solG[:,:,pny-1] = 0., 0., 0.
    for j in range(pny):
        solG[:,pnx-1,j] = j*dy*(1-j*dy)
        for i in range(pnx):
            x, y = i*dx, j*dy
            PE[i,j] = pe(x,y)
    for k in range(nk-1):
        for i in range(1,pnx-1):
            for j in range(1,pny-1):
                x, y = dx*i, dy*j
                solG[k+1,i,j] = 1/4*(solG[k,i+1,j]+solG[k+1,i-1,j]+solG[k,i,j+1]+solG[k+1,i,j-1]-dx**2*(6*x*y*(1-y)-2*x**3))
        R2 = (np.sum((solG[k,:,:] - solG[k-1,:,:])**2)/(pnx*pny))**0.5
#        print(R2)
        if R2<eps:
            nn = k-1
#           print(nn)
            nn2[ii] = nn
            break
    cs1 = axes[0,ii].contourf(XX,YY,solG[nn,:,:],levels=[-0.04+0.04*i for i in range(9)])
    cs2 = axes[1,ii].contourf(XX,YY,solG[nn,:,:]-PE)
    fig.colorbar(cs1,ax=axes[0,ii])
    fig.colorbar(cs2,ax=axes[1,ii])
    axes[0,ii].set_title("$\Delta x$="+str(dx))
    axes[1,ii].set_title("anomaly")

print(nn2)

cs3 = axes[0,lx].contourf(XX,YY,PE,levels=[-0.04+0.04*i for i in range(9)])
fig.colorbar(cs3,ax=axes[0,lx])
axes[1,lx].axis('off')
axes[0,lx].set_title("exact")
plt.tight_layout()
plt.savefig("./HW5-1_2.png")
plt.show()

#SOR
fig, axes = plt.subplots(2,lx+1)
fig.set_figheight(ht)
fig.set_figwidth(wd)

for ii in range(lx):
    pnx, pny = int(nx[ii]), int(ny[ii])
    dx, dy = xlen/(pnx-1), ylen/(pny-1) #put this in do loop!
    XX, YY = np.meshgrid(np.linspace(0,1,pnx),np.linspace(0,1,pny))
    solS = np.full((nk,pnx,pny),np.nan)
    PE = np.full((pnx,pny),np.nan)
    solS[0,:,:], solS[0,:,:], solS[0,:,:] = 0., 0., 0.
    solS[:,0,:], solS[:,:,0], solS[:,:,pny-1] = 0., 0., 0.
    for j in range(pny):
        solS[:,pnx-1,j] = j*dy*(1-j*dy)
        for i in range(pnx):
            x, y = i*dx, j*dy
            PE[i,j] = pe(x,y)
    for k in range(nk-1):
        for i in range(1,pnx-1):
            for j in range(1,pny-1):
                x, y = dx*i, dy*j
                solS[k+1,i,j] = beta/4*(solS[k,i+1,j]+solS[k+1,i-1,j]+solS[k,i,j+1]+solS[k+1,i,j-1]-dx**2*(6*x*y*(1-y)-2*x**3)) + (1-beta)*solS[k,i,j]
        R2 = (np.sum((solS[k,:,:] - solS[k-1,:,:])**2)/(pnx*pny))**0.5
#        print(R2)
        if R2<eps:
            nn = k-1
#            print(nn)
            nn3[ii] = nn
            break
    cs1 = axes[0,ii].contourf(XX,YY,solS[nn,:,:],levels=[-0.04+0.04*i for i in range(9)])
    cs2 = axes[1,ii].contourf(XX,YY,solS[nn,:,:]-PE)
    fig.colorbar(cs1,ax=axes[0,ii])
    fig.colorbar(cs2,ax=axes[1,ii])
    axes[0,ii].set_title("$\Delta x$="+str(dx))
    axes[1,ii].set_title("anomaly")

print(nn3)

cs3 = axes[0,lx].contourf(XX,YY,PE,levels=[-0.04+0.04*i for i in range(9)])
fig.colorbar(cs3,ax=axes[0,lx])
axes[1,lx].axis('off')
axes[0,lx].set_title("exact")
plt.tight_layout()
plt.savefig("./HW5-1_3_"+str(beta)+".png")
plt.show()

print("SUMMARY")
print("Jacobi:",nn1)
print("Gauss-Seidal:",nn2)
print("SOR(beta =",beta,"):",nn3)







