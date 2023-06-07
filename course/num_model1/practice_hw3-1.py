import numpy as np
import matplotlib.pyplot as plt
import sys

"""
1. Write a program to solve
	y' = -[2tanh 2t]y 	for 0<=t<=30, y(0) = 1

	using the following schemes: (i) forard Euler; (ii) backward Euler; (iii) Trapezoidal method;
	(iv) Second-order Runge-Kutta method.
"""
#(1) Try values of delt = 0.2, 0.9, 1.1, 2.5
#(2) Compare (graphically) the results with the exact solution.

def FoE(yn,t,dt):
	return (1-2*np.tanh(2*t)*dt)*yn

def BoE(yn,t,dt):
	return 1/(1+2*np.tanh(2*(t+dt))*dt)*yn

def Trm(yn,t,dt):
	return (1-np.tanh(2*t)*dt)/(1+np.tanh(2*(t+dt))*dt)*yn

def RK2(yn,t,dt):
	yn1t = -2*np.tanh(2*t)*yn*dt+yn
	return (-np.tanh(2*(t+dt))*yn1t-np.tanh(2*t)*yn)*dt+yn

t = 30
dt = np.array([0.2,0.9,1.1,2.5])
N = [int(t/dt[0]+1),int(t/dt[1]+1),int(t/dt[2]+1),int(t/dt[3]+1)]

tt1 = np.array([i*t/N[0] for i in range(N[0])])
tt2 = np.array([i*t/N[1] for i in range(N[1])])
tt3 = np.array([i*t/N[2] for i in range(N[2])])
tt4 = np.array([i*t/N[3] for i in range(N[3])])

yy1 = np.full((N[0],5),np.nan)
yy2 = np.full((N[1],5),np.nan)
yy3 = np.full((N[2],5),np.nan)
yy4 = np.full((N[3],5),np.nan)

yy1[0,:] = 1.
yy2[0,:] = 1.
yy3[0,:] = 1.
yy4[0,:] = 1.

DT = dt[0]
for i in range(N[0]-1):
	yy1[i+1,0] = FoE(yy1[i,0],tt1[i],DT)
	yy1[i+1,1] = BoE(yy1[i,1],tt1[i],DT)
	yy1[i+1,2] = Trm(yy1[i,2],tt1[i],DT)
	yy1[i+1,3] = RK2(yy1[i,3],tt1[i],DT)

DT = dt[1]
for i in range(N[1]-1):
	yy2[i+1,0] = FoE(yy2[i,0],tt2[i],DT)
	yy2[i+1,1] = BoE(yy2[i,1],tt2[i],DT)
	yy2[i+1,2] = Trm(yy2[i,2],tt2[i],DT)
	yy2[i+1,3] = RK2(yy2[i,3],tt2[i],DT)

DT = dt[2]
for i in range(N[2]-1):
	yy3[i+1,0] = FoE(yy3[i,0],tt3[i],DT)
	yy3[i+1,1] = BoE(yy3[i,1],tt3[i],DT)
	yy3[i+1,2] = Trm(yy3[i,2],tt3[i],DT)
	yy3[i+1,3] = RK2(yy3[i,3],tt3[i],DT)

DT = dt[3]
for i in range(N[3]-1):
	yy4[i+1,0] = FoE(yy4[i,0],tt4[i],DT)
	yy4[i+1,1] = BoE(yy4[i,1],tt4[i],DT)
	yy4[i+1,2] = Trm(yy4[i,2],tt4[i],DT)
	yy4[i+1,3] = RK2(yy4[i,3],tt4[i],DT)

yy1[:,4] = 1/np.cosh(2*tt1)
yy2[:,4] = 1/np.cosh(2*tt2)
yy3[:,4] = 1/np.cosh(2*tt3)
yy4[:,4] = 1/np.cosh(2*tt4)
	

fig, axes = plt.subplots(2,2)
fig.set_figheight(6)
fig.set_figwidth(10)

lw = 0.8

lg = ['Forward Euler','Backward Euler','Trapezoidal','2nd Runge-Kutta','exact']
cl = ['tab:blue','tab:orange','tab:green','tab:red','k']

for i in range(5):
	axes[0,0].plot(tt1,yy1[:,i],color=cl[i],linewidth=lw,label=lg[i])
	axes[0,1].plot(tt2,yy2[:,i],color=cl[i],linewidth=lw,label=lg[i])
	axes[1,0].plot(tt3,yy3[:,i],color=cl[i],linewidth=lw,label=lg[i])
	axes[1,1].plot(tt4,yy4[:,i],color=cl[i],linewidth=lw,label=lg[i])


axes[0,0].set_title("$\Delta t$=0.2")
axes[0,1].set_title("$\Delta t$=0.9")
axes[1,0].set_title("$\Delta t$=1.1")
axes[1,1].set_title("$\Delta t$=2.5")
plt.legend()
plt.tight_layout()

plt.savefig('./HW3-1_2a.png')
plt.show()

fig, axes = plt.subplots(2,2)
fig.set_figheight(6)
fig.set_figwidth(10)

for i in range(5):
    axes[0,0].plot(tt1,yy1[:,i],color=cl[i],linewidth=lw,label=lg[i])
    axes[0,1].plot(tt2,yy2[:,i],color=cl[i],linewidth=lw,label=lg[i])
    if i != 0 and i != 3:
	    axes[1,0].plot(tt3,yy3[:,i],color=cl[i],linewidth=lw,label=lg[i])
	    axes[1,1].plot(tt4,yy4[:,i],color=cl[i],linewidth=lw,label=lg[i])


axes[0,0].set_title("$\Delta t$=0.2")
axes[0,0].set_xlim(0,5)
axes[0,0].set_ylim(0,0.2)
axes[0,0].legend()
axes[0,1].set_title("$\Delta t$=0.9")
axes[0,1].set_xlim(0,5)
axes[0,1].set_ylim(-0.1,0.25)
axes[1,0].set_title("$\Delta t$=1.1")
axes[1,1].set_title("$\Delta t$=2.5")
plt.tight_layout()

plt.savefig('./HW3-1_2b.png')
plt.show()







#(4) plot local error at t=3.0 and t=30.0 with respect to delt(log-log plot), and discuss how the numerical error evolves in terms of accuracy and stability.

tlen = 3
nlen = 300
st = 1

err3 = np.zeros((nlen-st,4))

for i in range(st,nlen):
	tt = np.array([tlen/i*j for j in range(i+1)])
	DT = 3/i
	yy = np.full((i+1,4),np.nan)
	yy[0,:] = 1.
	for j in range(i):
		yy[j+1,0] = FoE(yy[j,0],tt[j],DT)
		yy[j+1,1] = BoE(yy[j,1],tt[j],DT)
		yy[j+1,2] = Trm(yy[j,2],tt[j],DT)
		yy[j+1,3] = RK2(yy[j,3],tt[j],DT)
	err3[i-st,:] = (np.abs(yy[i,:] - 1/np.cosh(2*3)))/(1/np.cosh(2*3))


delt = np.array([tlen/j for j in range(st,nlen)])

lg = ['Forward Euler','Backward Euler','Trapezoidal','2nd Runge-Kutta']

for i in range(4):
	plt.plot(delt,err3[:,i],label=lg[i])

plt.yscale("log")
plt.xscale("log")
#plt.xlim(0.01,1.)
plt.xlabel("Size of h")
plt.ylabel("Error")

plt.legend()
plt.savefig('./HW3-1_4a.png')
plt.show()

tlen = 3
nlen = 300
st = 10

err3 = np.zeros((nlen-st,4))

for i in range(st,nlen):
    tt = np.array([tlen/i*j for j in range(i+1)])
    DT = 3/i
    yy = np.full((i+1,4),np.nan)
    yy[0,:] = 1.
    for j in range(i):
        yy[j+1,0] = FoE(yy[j,0],tt[j],DT)
        yy[j+1,1] = BoE(yy[j,1],tt[j],DT)
        yy[j+1,2] = Trm(yy[j,2],tt[j],DT)
        yy[j+1,3] = RK2(yy[j,3],tt[j],DT)
    err3[i-st,:] = (np.abs(yy[i,:] - 1/np.cosh(2*3)))/(1/np.cosh(2*3))


delt = np.array([tlen/j for j in range(st,nlen)])

lg = ['Forward Euler','Backward Euler','Trapezoidal','2nd Runge-Kutta']

for i in range(4):
    plt.plot(delt,err3[:,i],label=lg[i])

plt.yscale("log")
plt.xscale("log")
plt.xlim(0.01,1.)
plt.xlabel("Size of h")
plt.ylabel("Error")

plt.legend()
plt.savefig('./HW3-1_4a2.png')
plt.show()






##for t = 30

tlen = 30
nlen = 300
st = 1

err30 = np.zeros((nlen-st,4))

for i in range(st,nlen):
    tt = np.array([tlen/i*j for j in range(i+1)])
    DT = tlen/i
    yy = np.full((i+1,4),np.nan)
    yy[0,:] = 1.
    for j in range(i):
        yy[j+1,0] = FoE(yy[j,0],tt[j],DT)
        yy[j+1,1] = BoE(yy[j,1],tt[j],DT)
        yy[j+1,2] = Trm(yy[j,2],tt[j],DT)
        yy[j+1,3] = RK2(yy[j,3],tt[j],DT)
    err30[i-st,:] = (np.abs(yy[i,:] - 1/np.cosh(2*30)))/(1/np.cosh(2*30))

print(err30)

delt = np.array([tlen/j for j in range(st,nlen)])

lg = ['Forward Euler','Backward Euler','Trapezoidal','2nd Runge-Kutta']

for i in range(4):
    plt.plot(delt,err30[:,i],label=lg[i])

plt.yscale("log")
plt.xscale("log")
#plt.xlim(0.01,1.)
plt.xlabel("Size of h")
plt.ylabel("Error")

plt.legend()
plt.savefig('./HW3-1_4b.png')
plt.show()

tlen = 30
nlen = 3000
st = 100

err30 = np.zeros((nlen-st,4))

for i in range(st,nlen):
    tt = np.array([tlen/i*j for j in range(i+1)])
    DT = tlen/i
    yy = np.full((i+1,4),np.nan)
    yy[0,:] = 1.
    for j in range(i):
        yy[j+1,0] = FoE(yy[j,0],tt[j],DT)
        yy[j+1,1] = BoE(yy[j,1],tt[j],DT)
        yy[j+1,2] = Trm(yy[j,2],tt[j],DT)
        yy[j+1,3] = RK2(yy[j,3],tt[j],DT)
    err30[i-st,:] = (np.abs(yy[i,:] - 1/np.cosh(2*30)))/(1/np.cosh(2*30))

print(err30)

delt = np.array([tlen/j for j in range(st,nlen)])

lg = ['Forward Euler','Backward Euler','Trapezoidal','2nd Runge-Kutta']

for i in range(4):
    plt.plot(delt,err30[:,i],label=lg[i])

plt.yscale("log")
plt.xscale("log")
plt.xlim(0.01,1.)
plt.xlabel("Size of h")
plt.ylabel("Error")

plt.legend()
plt.savefig('./HW3-1_4b2.png')
plt.show()







