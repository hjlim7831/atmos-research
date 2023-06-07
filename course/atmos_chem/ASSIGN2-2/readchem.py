import numpy as np
import sys


################################# READCHEM ##################################
# MODULE READCHEM READS SPECIES NAMES, CHEMICAL RXNS, AND PHOTOLYSIS RXNS 
# FROM THE CHEMISTRY MECHANISM FILE.

# nact		= number of active species
# ninact	= number of inactive species
# nrxn		= number of active reactions
# r_ind		= index of reactants [nrxn, nreact]
# p_ind		= index of products [nrxn, rprod]

#filename = '../input/chem2.dat'
#filename = '../input/ispchem.dat'
#filename = '../input/tropchem.dat'
#filename = './chapman.dat'
filename = './chapman_mechanism.dat'
#filename = './tropchem.dat'


#-----------------------
# SET INITIAL VALUES
#-----------------------

# READ CHEMISTRY FILE
chemfile = open(filename)

lines = chemfile.readlines()

b, e = [], []
i = 0
for line in lines:
    if line.strip() =='BEGIN':
        b.append(i)
    if line.strip()=='END':
        e.append(i)
    i = i+1

specieslist = lines[b[0]+1:e[0]]
rxnlist = lines[b[1]+1:e[1]]
photlist = lines[b[2]+1:e[2]]
photstart = photlist[0].split( )[1]
alllines = rxnlist + photlist

# MAKE LIST CONTAINING SPECIES INFORMATION

conc = np.zeros(len(specieslist), dtype='d')
act, inact, species, MW = [], [], [], []
for i in range(0, len(specieslist)):
    spc = specieslist[i].split( )
    conc[i] = float(spc[3])
    MW.append(float(spc[2]))
    species.append(spc[1])
    if spc[0].strip()=='A':
        act.append(spc[1])
    else:
        inact.append(spc[1])

print(act)
print(inact)

# MAKE LIST CONTAINING REACTION INFORMATION

react, prod, prod_coeff, react_coeff, A, B, C, Q, Fc = [], [], [], [], [], [], [], [], []
rxn_type, rxn_num = [], []
for i in range(0, len(alllines)):
    split = alllines[i].split( )
    Atemp, Btemp, Ctemp, Fctemp = [], [], [], []
    if split[0] == 'A':
        rxn_num.append(split[1])
        Q.append(split[5])
        Atemp.append(float(split[2]))
        Btemp.append(float(split[3]))
        Ctemp.append(float(split[4]))
        Fctemp.append(float(split[6]))
        if Q != '0':
            for j in range(1,int(split[5])+1):
                split2 = alllines[i+j].split( )
                Atemp.append(float(split2[0]))
                Btemp.append(float(split2[1]))
                Ctemp.append(float(split2[2]))
                Fctemp.append(float(split2[4])) 
        A.append(Atemp)
        B.append(Btemp)
        C.append(Ctemp)
        Fc.append(Fctemp) 
        reactant = alllines[i+int(Q[int(split[1])-1])+1].split( )
        r, rc = [], []
        while '+' in reactant:
            reactant.remove('+')
        for j in range(len(reactant)):
            r.append(reactant[j][1:])
            rc.append(np.double(reactant[j][0]))
        react.append(r)
        react_coeff.append(rc)

        product = alllines[i+int(Q[int(split[1])-1])+2].split( ) 
        p, pc = [], []
        while '+' in product:
            product.remove('+')
        for j in range(len(product)):
            p.append(product[j][5:]) 
            pc.append(product[j][1:5])
        prod.append(p)
        prod_coeff.append(pc)

    if split[0] == 'D':
         break

print(prod)

for i in range(0,int(photstart)-1):
    rxn_type.append('KIN')
for i in range(int(photstart),int(rxn_num[-1])+1):
    rxn_type.append('PHT')

print(prod_coeff)
print(react_coeff)

nrxn = len(react)
nkin = len(rxn_type[0:int(photstart)-1])
npht = len(rxn_type[int(photstart)-1:])
nact = len(act)
ninact = len(inact)
nspc = nact + ninact

print(nrxn)
print(nkin)
print(npht)
print(nact)
print(ninact)
print(nspc)

# Locate reactant, product index
rxn_ind = np.zeros((nrxn,3+11), dtype='i') - 1 	# assume rxns are termolecular
r_ind = np.zeros((nspc,nrxn), dtype='i') - 1
p_ind = np.zeros((nspc,nrxn), dtype='i') - 1
rnum = np.zeros(nspc, dtype='i') - 1
pnum = np.zeros(nspc, dtype='i') - 1

print(species)
print(react)
print(prod)

i = 0
for i in range(nrxn):
    for j in range(len(react[i])):
        try:
            p = species.index(react[i][j])
            rxn_ind[i,j] = p
#            rnum[p] += 1L
            rnum[p] += 1
            r_ind[p,rnum[p]] = i
        except ValueError:
            pass
    for j in range(len(prod[i])):
        try:
            p = species.index(prod[i][j])
            rxn_ind[i,j+3] = p
#			pnum[p] += 1L
            p_ind[p,pnum[p]] = i
        except ValueError:
            pass
    i = i + 1

print(rxn_ind)
print(rnum)
print(pnum)
print(r_ind)
print(p_ind)

print("********************************************")
print("*** Initial concentration (mixing ratio) ***")
for i in range(nact):
   print(act[i], "	= ", conc[i])
for i in range(ninact):
   print(inact[i], "	= ", conc[i+nact])
print("********************************************")

#############################################################################
############################# END OF READCHEM ###############################
#############################################################################
