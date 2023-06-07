import numpy as np
import matplotlib.pyplot as plt

dx1 = 0.1
x1 = 100

wx1 = int(x1/dx1)

dx2 = 1000

alpha = np.array([i*dx1 for i in range(wx1)])
kdelx = np.array([np.pi*i/dx2 for i in range(dx2)])
print(alpha)
print(kdelx)

Ak1 = np.full((wx1,dx2),np.nan)
Ak2 = np.full((wx1,dx2),np.nan)

for i in range(wx1):
	for j in range(dx2):
		Ak1[i,j] = (alpha[i]*np.cos(kdelx[j])+(1-(alpha[i]*np.sin(kdelx[j]))**2)**0.5)/(1+alpha[i])
		Ak2[i,j] = (alpha[i]*np.cos(kdelx[j])-(1-(alpha[i]*np.sin(kdelx[j]))**2)**0.5)/(1+alpha[i])

Xmesh, Ymesh = np.meshgrid(kdelx,alpha)

plt.figure(figsize=(6,6))

cp = plt.contourf(Xmesh,Ymesh,Ak1)
plt.colorbar(cp)
plt.show()

plt.figure(figsize=(6,6))
cp = plt.contourf(Xmesh,Ymesh,Ak2)
plt.colorbar(cp)
plt.show()









