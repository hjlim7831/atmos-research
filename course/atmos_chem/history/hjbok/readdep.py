import numpy as np
import sys
from readchem import species


filename = '../input/deposition.dat'

depfile = open(filename)

lines = depfile.readlines()

name,land_con = [],[]
#print lines
#sys.exit("stop")
for i in range(0,len(lines)):
	split = lines[i].split()
	name.append(split[0])
	land_con.append(float(split[1]))

#print species, land_con

sid,eid=[],[]
for i in range(len(species)):
	if species[i][0:2]=='NO':
		if 'NOX' in name:
			sid.append(i)
			j = name.index('NOX')
			eid.append(j)
	else:
		if species[i] in name:
			sid.append(i)
			j = name.index(species[i])
			eid.append(j)
#print sid, eid
#print land_con

depos = np.zeros(len(species), dtype='d')
#print species
#sys.exit("stop")
for i in range(len(sid)):
	deposid=sid[i]
	deposlandid=eid[i]
	depos[deposid] = (land_con[deposlandid])#/(1E+05)

#print total_dep_flux


