import numpy as np
from math import *


# MODULE READEMIS READS EMISSION DATA FROM THE EMISSION FILE.

def emiss(species,MW,dz): 

 filename = '../input/emission.dat'

 emisfile = open(filename)

 lines = emisfile.readlines()

 name, emission, cnum = [], [], []
 for i in range(4,len(lines)):
    split = lines[i].split( )
    name.append(split[0])
    emission.append(float(split[1]))
    cnum.append(int(split[2]))

 sid, eid = [], []
 for i in range(len(species)):
    if species[i] in name:
        sid.append(i)
        j = name.index(species[i])
        eid.append(j)

 emis = np.zeros(len(species), dtype='d')

 for i in range(len(sid)):
    emisid = sid[i]
    emissionid = eid[i]
    if cnum[emissionid] > 0.:
        emis[emisid] = (emission[emissionid] * 6.02E+23 * 1E+03)/(cnum[emissionid] * 12. * 86400. * dz[0] * 1E+02 * 1E+04)
    else:
        emis[emisid] = (emission[emissionid] * 6.02E+23 * 1E+03)/(MW[i] * 86400. * dz[0] * 1E+02 * 1E+04)

 return emis









