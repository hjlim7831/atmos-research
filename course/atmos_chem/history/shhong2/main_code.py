import matplotlib.pyplot as plt 
import numpy as np
import copy
import math 
#import myfuncts as mf 
from myfuncts import MIE
from myfuncts import BacEul
import time 
import read_chemtbl as rdtbl



# Define basic constants.
# All values are in [SI] MKS units, but only length unit [m] -> [cm].
Av = 6.02*((10.)**(23.))  # Avogadro number. [#]
R = 8.314  # Universal gas constant [J/mol/K]
e = math.e # Euler's number.



# Define variables varying with height.
hgt = np.array([20, 25, 30, 35, 40, 45, 50]) # [km]
P_z = np.array([79.501, 74.691, 70.121, 65.780, 61.660, 57.753, 54.048], dtype = 'float64')*((10.)**(3.))
T_z = np.array([275.154, 271.906, 268.659, 265.413, 262.166, 258.921, 255.676], dtype = 'float64')
w1_z = np.array([1.03, 2.10, 2.74, 3.29, 3.66, 3.85, 3.96], dtype = 'float64')
w3_z = np.array([0.98, 1.14, 1.39, 1.85, 2.37, 2.72, 2.98], dtype = 'float64')
k1_z = ( (10.)**(-14. + (w1_z/0.8) ) )
k3_z = ( (10.)**(-4. + (w3_z/0.8) ) )
n_z = len(hgt)




# Calculate evolution of species using theories with some assumtions.
Oz_theory = np.zeros(n_z, dtype = 'float64')





# Calculate evolution of species using models.
# And Save the N variables
t = 2000.            # total integration time [s]
dt = (10.)**(1.) # time mesh [s]
n_t = int(t//dt)         # total time steps for whole simulation time.
sv_step = 1 # Save concentration array only once in 1000 times.
n_sv = int(n_t//sv_step) + 1
n_spi = 4
Nsv = np.ones((n_z,n_spi,n_sv))
times = np.ones(n_sv)



for z in range(0, n_z): 
	P = P_z[z] # atmospheric pressure [Pa]
	T = T_z[z]  # temperature [K]
	CtoN = ((Av*P)/(R*T))*((10.)**(-6.))  # [#/m^3] -> [#/cm^3]
	NtoC = 1./CtoN
	


	# Calculate "k_arr" rate constants array.
	A = copy.deepcopy(np.array(rdtbl.A , dtype = 'float64'))
	B = copy.deepcopy(np.array(rdtbl.A , dtype = 'float64'))
	C = copy.deepcopy(np.array(rdtbl.A , dtype = 'float64'))
	k_arr = A*((300./T)**(B))*np.exp(C/T)
	k_arr = k_arr[:,0]
	k_arr[3-1] = k3_z[z]
	k_arr[4-1] = k1_z[z]
	


	# Set the initial condition.
	Npre = copy.deepcopy(rdtbl.conc)*CtoN # [#/cm^3]
	n_spi = len(Npre)
	react_arr = copy.deepcopy(rdtbl.react_arr)
	react_arr_gam = copy.deepcopy(rdtbl.react_arr_gam)
	prod_arr = copy.deepcopy(rdtbl.prod_arr)
	loss_arr = copy.deepcopy(rdtbl.loss_arr)


	# Calculate steady state using theories with some assumtions.
	Oz_theory[z] = (((k_arr[4-1]*k_arr[1-1])/(k_arr[2-1]*k_arr[3-1]))**(0.5))*(0.21)*((Npre[4-1])**(1.5))


	# Calculate evolution of species.
	# And Save the N variables
	for i in range(0, n_t):
	

		# First, Calculate "prod_rate" & "loss_rate".
		#react_rate = k_arr*np.prod(Npre**react_arr, axis=1)
		#react_rate_gam = k_arr*np.prod(Npre**react_arr_gam, axis=2)
		#prod_rate = np.sum(react_rate*prod_arr.T, axis=1)
		#loss_rate = np.sum(react_rate*loss_arr.T, axis=1)
		#loss_gamm = np.sum(react_rate_gam*loss_arr.T, axis=1)
	
		# Calculate Nnew.
		Nnew = MIE(Npre,dt,k_arr,react_arr,react_arr_gam,prod_arr,loss_arr)
		#print(" time step = " + str(i) + ".")
		#Nnew = BacEul(Npre,dt,prod_rate,loss_gamm)
	
		# Save N variables.
		if ((i%sv_step)==0) :
			sv_idx = int(i//sv_step)
			Nsv[z,:,sv_idx] = copy.deepcopy(Nnew)
			times[sv_idx] = float(i)*dt
	
	

		# Check whether equilibrium or not.
		diff = math.sqrt(np.dot((Nnew - Npre),(Nnew - Npre)))
		if (diff<((10.)**(-12.))) :
			print("Succesfully Finished, at " + str(i) + "-th step, at " + str(i*dt) + " [s]")
			print(Nnew)
			end_sv = int(i//sv_step)
			break
		elif (i == (n_t-1)) :
			print("time is finished.")
			print(Nnew)
			end_sv = int(i//sv_step)
		else :
			Npre = copy.deepcopy(Nnew)
	
	
		
	#end_time = time.time()
	#print(" the time required to run this code : ")
	#print(str((end_time - start_time)/60.)+"[min]")


	Nsv = copy.deepcopy( Nsv )     # consider "decf" & [m^3] -> [cm^3]	




# Draw the 1st figure.
days = times[:(end_sv+1)]/(3600*24)
plt.figure()
plt.plot(days, np.reshape(Nsv[1-1,2-1,:(end_sv+1)],end_sv+1), label = 'O$_3$ at 20km')
plt.plot(days, np.reshape(Nsv[2-1,2-1,:(end_sv+1)],end_sv+1), label = 'O$_3$ at 25km')
plt.plot(days, np.reshape(Nsv[3-1,2-1,:(end_sv+1)],end_sv+1), label = 'O$_3$ at 30km')
plt.plot(days, np.reshape(Nsv[4-1,2-1,:(end_sv+1)],end_sv+1), label = 'O$_3$ at 35km')
plt.plot(days, np.reshape(Nsv[5-1,2-1,:(end_sv+1)],end_sv+1), label = 'O$_3$ at 40km')
plt.plot(days, np.reshape(Nsv[6-1,2-1,:(end_sv+1)],end_sv+1), label = 'O$_3$ at 45km')
plt.plot(days, np.reshape(Nsv[7-1,2-1,:(end_sv+1)],end_sv+1), label = 'O$_3$ at 50km')
plt.xlabel('time (day)')
plt.ylabel('number concentration (cm$^{-3}$)')
plt.title('MIE solution, dt = 10 (s)')
#plt.xlim(1000.,1.)
#plt.yscale('log')
plt.legend()
plt.savefig('./Assign2_1.png')
#plt.show()


# Draw the 2nd figure.
plt.figure()
plt.plot(np.reshape(Nsv[:,2-1,end_sv]/((10)**(12.)), n_z), hgt, label = 'O$_3$ : simulation')
plt.plot(Oz_theory/((10)**(12.)), hgt, label = 'O$_3$ : theory')
plt.xlabel('number concentration (10$^{12}$ cm$^{-3}$)')
plt.ylabel('height (km)')
plt.title('MIE solution, dt = 10 (s)')
plt.ylim(10.,50.)
plt.legend()
plt.savefig('./Assign2_2.png')


# Show All the figures
plt.show()
