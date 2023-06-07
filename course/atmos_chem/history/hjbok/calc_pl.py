import numpy as np
from readchem import act,nact,rxn_ind,rnum,r_ind,prod_coeff,prod,react_coeff,react
import sys
import matplotlib.pyplot as plt

print(nact)
print(act)

def calc_pro(init_conc,pnum,p_ind,rate_co):
    pro = np.zeros(nact, dtype='d')
    for ii in range(nact):
     for i in range(pnum[ii]+1):               	# num = pnum/rnum 
        n = p_ind[ii][i]
        rate = rate_co[n]			# ind = p_ind/r_ind
        for j in range(3):                   
           pro_ind = rxn_ind[n][j]		# locate "jth" reactant of the "nth" rxn
           if pro_ind >= 0:
               rcoeff = np.double(react_coeff[n][j]) 
               prodid = prod[n].index(act[ii])
               pcoeff = np.double(prod_coeff[n][prodid])	# find branching ratio of each product
               rate *= (init_conc[pro_ind])**rcoeff
               rate = rate * pcoeff	
        pro[ii] += rate  

    return pro

def calc_lo(init_conc,rnum,r_ind,rate_co):
    lo = np.zeros(nact, dtype='d')
    for ii in range(nact):
     for i in range(rnum[ii]+1):
        n = r_ind[ii][i]
        rate = rate_co[n]
        for j in range(3):
           lo_ind = rxn_ind[n][j]
           if lo_ind >= 0.:
               rcoeff = np.double(react_coeff[n][j])
               rate *= (init_conc[lo_ind])**rcoeff
               rate = rate * rcoeff
        lo[ii] += rate

    return lo


def calc_implo(init_conc,rate_co):
    imp_lo = np.zeros(nact, dtype='d')
    for ii in range(nact):
     for i in range(rnum[ii]+1):
        n = r_ind[ii][i]			# n = reaction number
        l_rate = rate_co[n] 
        for j in range(3):
           loss_ind = rxn_ind[n][j] 
           if loss_ind >= 0:
               rcoeff = np.double(react_coeff[n][j]) 
               if loss_ind != ii: # exclude species of interest in multiplication
                l_rate *= (init_conc[loss_ind])**rcoeff
                l_rate = l_rate * rcoeff
        imp_lo[ii] += l_rate            	# implicit loss term
 
    return imp_lo


 
