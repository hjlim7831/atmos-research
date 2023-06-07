import numpy as np
from readchem import pnum,rnum,p_ind,r_ind,nact,nrxn
from calc_pl import calc_pro
from calc_pl import calc_lo
from calc_pl import calc_implo
import sys


################################# ITERATION ###################################


def iteration(h_mie,conc,rate_co):

# 1) Set initial estimates to initial conc

 est_for = np.copy(conc)
 est_back = np.copy(conc)
#print 'in iteration', conc
 

# 2) Set maximum estimate to initial conc

 est_max = np.copy(conc)

#--------------------------
# ITERATION STARTS HERE!!!
#--------------------------

 Np = 0 			# iteration counter
 IM = 100			# maximum number of iteration permitted
 if nrxn <= 15:
  crit = 30			# convergence criteria
 elif nrxn > 15 and nrxn <= 50:
  crit = 10
 elif nrxn > 50:
  crit = 5
 LT = 1e+6
 re_max = np.copy(conc)
 stat = 0
 for itr in range(IM):
# 3) Estimate rxn rates from b_euler values
# 4) Sum production, loss, implicit loss terms
# 5) Estimate conc with b_euler
# 6) Estimate conc with f_euler
 
  pro = calc_pro(est_back,pnum,p_ind,rate_co)
  lo = calc_lo(est_back,rnum,r_ind,rate_co)
  imp_lo = calc_implo(est_back,rate_co) 
#  print 'prod', pro[14] 
#  print 'loss', lo[14]
#  print 'imp loss', imp_lo[14]
  for j in range(nact):
   est_back[j] = ( conc[j] + h_mie * pro[j] )/( 1. + h_mie * imp_lo[j] )	# 5
   est_for[j] = conc[j] + h_mie * (pro[j] - lo[j]) 			# 6


 # 7) Check convergence 
 # METHOD 1--------------------------------------------------------------
 # check if positive
# pos_or_neg = []
# for i in range(nact):		
#    if est_for[i] >= 0.:  
#        pos_or_neg.append(1) 	# label '1' if conc >= 0 (positive)
#    else:
#        pos_or_neg.append(0)	# label '0' if conc < 0 (negative)
 #-----------------------------------------------------------------------
 # METHOD 2--------------------------------------------------------------
 # find index for medium and long lived species
  ml_lspc = []
  for i in range(nact):
     if h_mie * imp_lo[i] < LT:
         ml_lspc.append(i)

  # check if positive 
  pos_or_neg = []
  for i in ml_lspc:
     if est_for[i] >= 0.:
         pos_or_neg.append(1)
     else:
         pos_or_neg.append(0)
 #-----------------------------------------------------------------------

  if sum(pos_or_neg) == len(pos_or_neg)*1:      # check the sum of elements in [pos_or_neg] 
     Np = Np + 1                        # if so, increase counter
  else:
     Np = 0                     # reset counter



 # If Np reaches convergence criteria then system is converged 
 # 9) "Cap" the implicit estimate 
  if Np == crit:
     break

  for i in range(nact): 
     re_max[i] = max(conc[i],est_back[i])            # reset max
     est_back[i] = min(est_back[i],est_max[i])       # limit min
     est_max[i] = re_max[i]
     

 # If convergence does not occur after IM then reduce timestep
  if itr == IM-1:
     stat = 1


#---------------    
# END ITERATION 
#---------------

# SET FINAL CONCENTRATION TO LAST ESTIMATE
 for i in range(nact):
     if h_mie*imp_lo[i] >= LT:
         conc[i] = np.copy(est_back[i])
     else:
         conc[i] = np.copy(est_for[i])

#print itr, "iterations made" 
# print 'H2O2', (conc[13]/2.46e+19)*1E+09 
 itr_res = {'estimate':conc, 'status':stat}

 return itr_res

#############################################################################
############################ END OF ITERATION ###############################
#############################################################################

