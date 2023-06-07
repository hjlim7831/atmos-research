import numpy as np
from readchem import *
import matplotlib.pyplot as plt
import matplotlib.dates as dt
import dateutil
import sys
from calc_coeff import calc_coeff
from cossza import cossza
from calc_pl import calc_rate
from calc_pl import calc_implo
from iteration import iteration
from math import *
from reademis import emiss
import datetime
from readdep import depos
from diffusion import diffusion
from scipy.io import netcdf

#################################### MAIN PROGRAM ###################################
# THIS PROGRAM IS THE MAIN LEVEL DRIVER PROGRAM FOR THE SIMPLE COLUMN MODEL.

save_nc		= 'F'
start           = '2016,06,15'
lat             = 37.5
lon             = 127.
chem_status     = 'T'
emis_status     = 'F'
depos_status    = 'F'
diff_status	= 'F'

h               = 60                    # timestep size [sec]
end_t           = 86400      	 # end time of simulation
solver          = 'MIE'
nsteps          = int(float(end_t)/h)                                


# VERTICAL GRID SETUP ################################################################

R 		= 8.31                  # J/Kmol        
lapse_rate 	= 6.49E-03              # K/m
Av 		= 6.02E+23              # molec/mole
nlev 		= 10
Ps		= 1000. 		# hPa
Pt		= 700.

P = np.zeros(nlev+1, dtype='d')		# pressure at each boundary of the layer (hPa)
lev = np.zeros(nlev+1, dtype='d')	# altitude of each boundary (m)

result = np.zeros((nlev,nspc),dtype='d')
result[0,:] = conc
empty = np.zeros((nlev-1,nact),dtype='d') + 1E-30

for i in range(nlev+1):
 P[i] = Ps - (Ps-Pt)/nlev*i		# no topography -> constant dP between layers
 lev[i] = 7500*log(Ps/P[i])		# assume scale height = 7.5 km
 result[1:,0:nact] = empty
 result[1:,nact:] = conc[nact:]		# assume constant mixing ratios of inactive species

dz = np.zeros(nlev,dtype='d')
for i in range(nlev):
 dz[i] = lev[i+1]-lev[i]


# INITIALIZE TIME ###################################################################

currtime = 0. 						# start time

init_J = np.copy(A[int(photstart)-1:]) 			# initial photolysis rate

# CREATE OUTPUT NETCDF FILE #########################################################

if save_nc == 'T':

 out = netcdf.netcdf_file('../output/modeloutput.nc', 'w')

 out.createDimension('time', nsteps+1)
 out.createDimension('levels', nlev)
 out.createDimension('tracers', nspc)

 sim_time = out.createVariable('sim_time', 'd', ('time',))
 sim_time[0] = currtime
 sim_time.units = 'seconds since start of simulation'

 for i in range(nspc):
  if i == 0:
   tracer = np.str(np.copy(species[i]))
   tracer = out.createVariable(tracer, 'd', ('time','levels'))
   tracer[0,:] = result[:,i]
   tracer.units = 'v/v'
  else:
   trctemp = np.str(np.copy(species[i]))
   trctemp = out.createVariable(trctemp, 'd', ('time','levels'))
   trctemp[0,:] = result[:,i]
   trctemp.units = 'v/v'
   tracer = [tracer, trctemp]

 air_T = out.createVariable('air_T', 'd', ('time','levels'))
 air_T.units = 'K'

 air_D = out.createVariable('air_D', 'd', ('time','levels'))
 air_D.units = 'molec/cm3'

 if emis_status == 'T':
  emission = out.createVariable('emission', 'd', ('time','tracers'))
  emission.units = 'molec/s'

# TIMESTEP LOOP #####################################################################

print "** B E G I N  T I M E  S T E P P I N G ! ! !"

for t in range(1,nsteps):

 print '*******************************************'

#-----------------------------------------------------------------------------------
 # Diurnal variation of surface temperature ( local time = UTC + 9hrs )
 Ts = 273. + 10*sin((2*pi/86400.)*(currtime-1*3600.)) + 25.

 # Air temperature at each level
 T = np.zeros(nlev, dtype='d')
 T[0] = Ts
 for i in range(nlev-1):
  T[i+1] = Ts - lapse_rate*dz[i]

 # Air density at each level
 Nd = np.zeros(nlev, dtype='d')
 for i in range(nlev):
  Nd[i] = 1E-04*P[i]*Av*(R*T[i])**(-1)               # molec/cm3

 # mixing ratio -> number density
 for i in range(nlev):
  result[i] = result[i] * Nd[i]   

#-----------------------------------------------------------------------------------
 # EMISSION #

 if emis_status == 'T':

        emis = emiss(species,MW,dz)
        result[0] = np.copy(result[0]) + emis*h
        if save_nc == 'T':
         # save value
         emission[t,:] = emis 
        
#-----------------------------------------------------------------------------------
 # DRY DEPOSITION #

 if depos_status == 'T':

        result[0] = np.copy(result[0]) - depos*np.copy(result[0])*h

#-----------------------------------------------------------------------------------

# VERTICAL CALCULATION LOOP ########################################################

 # CHEMISTRY #

 if chem_status == 'T':
 
  for z in range(nlev):

   # Before calculation adjust rate coeffecients
   rate_co = np.zeros(nrxn, dtype='d')

   for i in range(nkin):
         p1 = species.index('M')
         p2 = species.index('H2O')
         M_conc = result[z,p1] 
         H2O_conc = result[z,p2]
         rate_co[i] = calc_coeff(A[i],B[i],C[i],Q[i],Fc[i],T[z],M_conc,H2O_conc)
   for i in range(npht):
         rate_co[nkin+i] = init_J[i]
         cos_sza = cossza(start,currtime,lon,lat)
         if cos_sza > 0.:
             rate_co[nkin+i] = init_J[i] * cos_sza 
         else: 
             rate_co[nkin+i] = 0.


   # FORWARD EULER METHOD
   if solver == 'FWE':
 
         init_conc = result[z]
         pro = calc_rate(init_conc,pnum,p_ind,rate_co)
         lo = calc_rate(init_conc,rnum,r_ind,rate_co)
  
         for i in range(nact):
             result[z,i] = ( result[z,i] + h*( pro[i] - lo[i] ) )
        

   # BACKWARD EULER METHOD
   if solver == 'BWE':

         init_conc = result[z]
         pro = calc_rate(init_conc,pnum,p_ind,rate_co)
         imp_lo = calc_implo(init_conc,rate_co)
    
         for i in range(nact):
             result[z,i] = ( result[z,i] + h*pro[i] )/( 1. + h*imp_lo[i] )


   # MIE 
   if solver == 'MIE':

         init_conc = result[z]
         h_mie = h		
         n_mie = 1
         while range(n_mie):
          itr_res = iteration(h_mie,init_conc,rate_co)
          result[z] = itr_res['estimate']
          if itr_res['status'] == 0:
           break
          if itr_res['status'] == 1:
           print "Convergence failed! Reducing time step..."
           h_mie = h_mie * 0.5
           n_mie = n_mie * 2
  
 print 'before diff', result 
#---------------------------------------------------------------------------------
 # DIFFUSION #

 if diff_status == 'T':

  # Calculate total mass (molecules)
  mass1 = np.zeros(nspc, dtype='d')
  for z in range(nlev):
   for i in range(nspc):
    mass1[i] += dz[z] * result[z,i]

  # number density -> mixing ratio
  for i in range(nlev):
   result[i] = result[i] / Nd[i]

  # Start diffusion
  diff = diffusion(nlev,nspc,h,dz,lev)
  Az = diff[0]
  Bz = diff[1]
  Dz = diff[2]

  gamma = np.zeros((nlev,nact),dtype='d')
  alpha = np.zeros((nlev,nact),dtype='d')

  for i in range(nact):
   gamma[0,i] = -Dz[0,i]/Bz[0,i]
   alpha[0,i] = result[0,i]/Bz[0,i]
   for z in range(1,nlev):
         gamma[z,i] = -Dz[z,i]/(Bz[z,i] + Az[z,i]*gamma[z-1,i])
         alpha[z,i] = (result[z,i] - Az[z,i]*alpha[z-1,i])/(Bz[z,i] + Az[z,i]*gamma[z-1,i])

   result[nlev-1,i] = alpha[nlev-1,i]
   for z in range(nlev-2,-1,-1): 
    result[z,i] = alpha[z,i] + gamma[z,i]*result[z+1,i]
   
  # mixing ratio -> number density
  for i in range(nlev):
   result[i] = result[i] * Nd[i]

  # Calculate total mass after diffusion
  mass2 = np.zeros(nspc, dtype='d')
  for z in range(nlev):
   for i in range(nspc):
    mass2[i] += dz[z] * result[z,i]

  # Check mass conservation
  for i in range(nspc):
   if mass1[i] != mass2[i]:
    scale_factor = mass1[i]/mass2[i]
    result[:,i] = result[:,i] * scale_factor

  print 'after diff', result
#---------------------------------------------------------------------------------

 # number density -> mixing ratio
 for i in range(nlev):
  result[i] = result[i] / Nd[i]

 currtime = currtime + h
 print 'NO', result[:,0]

 if save_nc == 'T': 
  # save value
  air_T[t,:] = T
  air_D[t,:] = Nd
  for i in range(nspc):
   tracer[i][t,:] = result[:,i]
  sim_time[t] = currtime 

#print "*** Concentration after", end_t, "seconds ***"
#for i in range(nspc):
# print i, species[i], "	= ", timeseries[nsteps-1,i]
#print '********************************************'

# END OF TIME LOOP ###############################################################

if save_nc == 'T':
 # CLOSE OUTPUT FILE
 out.close()


##############################################################################
################################# END OF MAIN ################################
##############################################################################
