import numpy as np
import matplotlib.pyplot as plt
import sys
from mpl_toolkits.mplot3d import Axes3D
from matplotlib.animation import FuncAnimation

#(a) Initialize X, Y, and Z near the origin, say X(0) = Y(0) = -0.001, Z(0) = 0.
#Plot X,Y,Z versus time (integrate up to at least t = 70), and note that the solution is chaotic.

sig = 10.
b = 8/3
r = 28.

def dXdt(X,Y,dt):
	q1 = dt*(-sig*X+sig*Y)
	q2 = dt*(-sig*(X+q1/2)+sig*Y)
	q3 = dt*(-sig*(X+q2/2)+sig*Y)
	q4 = dt*(-sig*(X+q3)+sig*Y)
	return X + (q1+2*q2+2*q3+q4)/6

def dYdt(X,Y,Z,dt):
	q1 = dt*(-X*Z+r*X-Y)
	q2 = dt*(-X*Z+r*X-(Y+q1/2))
	q3 = dt*(-X*Z+r*X-(Y+q2/2))
	q4 = dt*(-X*Z+r*X-(Y+q3))
	return Y + (q1+2*q2+2*q3+q4)/6

def dZdt(X,Y,Z,dt):
	q1 = dt*(X*Y-b*Z)
	q2 = dt*(X*Y-b*(Z+q1/2))
	q3 = dt*(X*Y-b*(Z+q2/2))
	q4 = dt*(X*Y-b*(Z+q3))
	return Z + (q1+2*q2+2*q3+q4)/6

t, dt = 100., 0.01
dlen = int(t/dt)

T = np.array([i*dt for i in range(dlen)])

X, Y, Z = np.full(dlen,np.nan), np.full(dlen,np.nan), np.full(dlen,np.nan)
X[0], Y[0], Z[0] = -0.001, -0.001, 0.

for i in range(dlen-1):
	X[i+1] = dXdt(X[i],Y[i],dt)
	Y[i+1] = dYdt(X[i],Y[i],Z[i],dt)
	Z[i+1] = dZdt(X[i],Y[i],Z[i],dt)

fig, axes = plt.subplots(3)

lw = 0.8

axes[0].plot(T,X,linewidth=lw)
axes[0].set_ylabel("X")
axes[1].plot(T,Y,linewidth=lw)
axes[1].set_ylabel("Y")
axes[2].plot(T,Z,linewidth=lw)
axes[2].set_ylabel("Z")
axes[2].set_xlabel("time (s)")
plt.savefig('HW3-2a.png')
plt.show()



#(b) Start another solution slightly away from the initial condition in part (a).
#How different are they? How far apart do they get from each other?
#Plot the difference between each component.
#You should note that the solution exhibits extreme sensitivity to initial conditions.
#Sensitive dependence to initial conditions is the essence of chaos theory and is caused by the non-linearity of the equations.

X1, Y1, Z1 = np.full(dlen,np.nan), np.full(dlen,np.nan), np.full(dlen,np.nan)
X1[0], Y1[0], Z1[0] = -0.001, -0.001, -0.001

for i in range(dlen-1):
    X1[i+1] = dXdt(X1[i],Y1[i],dt)
    Y1[i+1] = dYdt(X1[i],Y1[i],Z1[i],dt)
    Z1[i+1] = dZdt(X1[i],Y1[i],Z1[i],dt)

fig, axes = plt.subplots(3)

axes[0].plot(T,X-X1,linewidth=lw)
axes[0].set_ylabel("X-X1")
axes[1].plot(T,Y-Y1,linewidth=lw)
axes[1].set_ylabel("Y-Y1")
axes[2].plot(T,Z-Z1,linewidth=lw)
axes[2].set_ylabel("Z-Z1")
axes[2].set_xlabel("time (s)")
plt.savefig('HW3-2b1.png')
plt.show()

X2, Y2, Z2 = np.full(dlen,np.nan), np.full(dlen,np.nan), np.full(dlen,np.nan)
X2[0], Y2[0], Z2[0] = -0.001, -0.001, -0.0001

for i in range(dlen-1):
    X2[i+1] = dXdt(X2[i],Y2[i],dt)
    Y2[i+1] = dYdt(X2[i],Y2[i],Z2[i],dt)
    Z2[i+1] = dZdt(X2[i],Y2[i],Z2[i],dt)

fig, axes = plt.subplots(3)

axes[0].plot(T,X-X2,linewidth=lw)
axes[0].set_ylabel("X-X2")
axes[1].plot(T,Y-Y2,linewidth=lw)
axes[1].set_ylabel("Y-Y2")
axes[2].plot(T,Z-Z2,linewidth=lw)
axes[2].set_ylabel("Z-Z2")
axes[2].set_xlabel("time (s)")
plt.savefig('HW3-2b2.png')
plt.show()


#(c) Solution initially close to each other move apart exponentially.
#However, there is an attractor (called strange attractor) that keeps the solution orbits bounded.
#For one case make a 3-D plot with X,Y and Z on the axes and time as the parameter.
#You may want to watch the evolution of the point (X,Y,Z) on your computer monitor.

fig = plt.figure(figsize=(8,8))

ax = fig.add_subplot(111,projection='3d')
ax.plot(X,Y,Z)
plt.savefig('HW3-2c1.png')
plt.show()


fig = plt.figure(figsize=(8,8))

ax = fig.add_subplot(111,projection='3d')
ax.plot(X1,Y1,Z1)
plt.savefig('HW3-2c2.png')
plt.show()







