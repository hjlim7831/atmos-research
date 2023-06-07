import numpy as np
import matplotlib.pyplot as plt
import matplotlib.dates as dt
import sys
from copy import *
from calc_solv import *
from calc_pli import *
from reader_phot import *
from math import *
import pickle

# Constants ####################################

R = 8.314
AN = 6.02e+23

nlev = 4
z0 = 20. # [km]
zt = 50. # [km]

solver = 'MIE'

# Define Variables varying with height
hgt = np.array([20, 30, 40, 50]) # [km]
P_z = np.array([5.53, 1.2, 0.28, 0.079], dtype = 'float64')*((10.)**(3.))
T_z = np.array([-56.5, -46.64, -22.8, -2.5], dtype = 'float64') + 273.15
w1_z = np.array([1.85, 5.3, 7.09, 7.85], dtype = 'float64')
w3_z = np.array([1.85, 2.65, 4.7, 5.79], dtype = 'float64')
k1_z = ( (100.)**(-7. + (w1_z/3.11) ) )
k3_z = ( (10.)**(-4. + (w3_z/3.11) ) )
n_z = len(hgt)

CONVz = 1e-6*P_z*AN/(R*T_z)

Ox_theory = np.zeros(n_z)

#print(wrate)

#t = 2000.
t = 20.
dt = 10.
n_t = int(t//dt)
sv_step = 1
n_sv = int(n_t//sv_step) + 1
n_spi = 4
result = np.zeros((n_z,n_spi,n_sv))
times = np.zeros(n_sv)

if solver != 'MIE':
	times = np.arange(0,t+dt,dt)


for z in range(n_z):
	P = P_z[z] ; T = T_z[z]
	k_arr = wrate
	k_arr[3-1] = k3_z[z]
	k_arr[4-1] = k1_z[z]
	result[z,:,0] = np.array(init)*CONVz[z]

	for i in range(n_t-1):
		init_conc = result[z,:,i]
		
		print(PROD(init_conc,k_arr,pnum,p_ind))
		
		if solver == 'MIE':
			h_mie = dt
			n_mie = 1
			while range(n_mie):
				itr_res = MIE(h_mie,init_conc,k_arr)
				result[z,:,i+1] = itr_res['estimate']
#				print(itr_res['estimate'])
				if itr_res['status'] == 0:
					times[i+1] = times[i] + h_mie
					break
				if itr_res['status'] == 1:
					print("Convergence failed! Reducing time step ...")
					h_mie *= 0.5
					n_mie *= 2

		if solver == 'BACK':
			result[z,:,i+1] = Back(init_conc,dt,k_arr)
			print(result[z,:,i+1])

llabel = ['20 km','30 km','40 km','50 km']

#print(result)

# Plot Section
pspi = 1
for j in range(n_z):
	plt.plot(times,result[j,pspi,:],label=llabel[j])

plt.legend()
plt.show()



#print(result)
#print(times)



