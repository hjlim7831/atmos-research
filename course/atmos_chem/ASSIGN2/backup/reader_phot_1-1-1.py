import numpy as np

inpf = 'chapman_mechanism.dat' # NOTE: MOVE THIS TO NAMELIST

# Data input #######################################################################
with open(inpf,'r') as f:
    lis = f.read()
    line = np.array(lis.splitlines())
    start = np.where(line == 'BEGIN')
    done = np.where(line == 'END')


# Coefficients #####################################################################
# NOTE: MOVE THIS TO MAIN

T = 298.
p = 101300
R = 8.314
AN = 6.02e+23
CONV = 1e-6*p*AN/(R*T)

# Data split #######################################################################

data1 = line[start[0][0]+1:done[0][0]]
data2 = line[start[0][1]+1:done[0][1]]
data3 = line[start[0][2]+1:done[0][2]]

# for data1 ########################################################################
# aori				: variables which indicate whether chemical species are active or inactive
# active_spec		: active species
# inactive_spec		: inactive species
# spec_name			: active_spec + inactive_spec
# mw				: moleculat weight
# init				: initial concentration
aori = []
active_spec = []
inactive_spec = []
spec_name = []
mw = []
init = []

for i in range(len(data1)):
    aori.append(data1[i].split()[0])
    spec_name.append(data1[i].split()[1])
    mw.append(data1[i].split()[2])
    if aori[i] == 'A':
        active_spec.append(data1[i].split()[1])
    else:
        inactive_spec.append(data1[i].split()[1])
    init.append(float(data1[i].split()[3]))

# for data2 #########################################################################
# coefA				: coefficient A
# coefB				: coefficient B
# coefC				: coefficient C
# reactants			: chemical species which react on each chemical reactions
# products			: chemical species which is produced on each chemical reactions
# react_rate		: reaction rate on each chemical species [this depends on Fc]




coefA = []
coefB = []
coefC = []
reactants = []
products = []
react_rate = []
for i in range(len(data2)):
    if len(data2[i].split()) == 7:
        coefA.append(data2[i].split()[2])
        coefB.append(data2[i].split()[3])
        coefC.append(data2[i].split()[4])
    else:
        if data2[i].split()[0][0] == '=':
            products.append(data2[i].replace(" ","").split("+"))
        elif data2[i].split()[1] == '+':
            reactants.append(data2[i].replace(" ","").split("+"))

for i in range(len(coefA)):
    react_rate.append(float(coefA[i])*(300./T)**float(coefB[i])*np.exp(float(coefC[i])/T))



react_coefs = []
prod_coefs = []
react_spec = []
prod_spec = []
for i in range(len(products)):
    pc = []
    ps = []
    for j in range(len(products[i])):
        if products[i][j] != '':
            pc.append(float(products[i][j].replace("=","")[0:5]))
            ps.append(products[i][j].replace("=","")[5:])
        else:
            pc.append(0.)
            ps.append('')
    prod_coefs.append(pc)
    prod_spec.append(ps)

for i in range(len(reactants)):
    rc = []
    rs = []
    for j in range(len(reactants[i])):
        if reactants[i][j] != '':
            rc.append(float(reactants[i][j][0]))
            rs.append(reactants[i][j][1:])
        else:
            rc.append(0.)
            rs.append('')
    react_coefs.append(rc)
    react_spec.append(rs)

#for data3
pcoefA = []
pcoefB = []
pcoefC = []
preactants = []
pproducts = []
for i in range(len(data3)):
    if len(data3[i].split()) == 7:
        pcoefA.append(data3[i].split()[2])
        pcoefB.append(data3[i].split()[3])
        pcoefC.append(data3[i].split()[4])
    else:
        if data3[i].split()[0][0] == '=':
            pproducts.append(data3[i].replace(" ","").split("+"))
        elif data3[i].split()[1] == '+':
            preactants.append(data3[i].replace(" ","").split("+"))
phot_rate = []
for i in range(len(pcoefA)):
        phot_rate.append(float(pcoefA[i])*(300./T)**float(pcoefB[i])*np.exp(float(pcoefC[i])/T))

preact_coefs = []
pprod_coefs = []
preact_spec = []
pprod_spec = []
for i in range(len(pproducts)):
        rc = []
        rs = []
        for j in range(len(pproducts[i])):
                if pproducts[i][j] != '':
                        rc.append(float(pproducts[i][j].replace("=","")[0:4]))
                        rs.append(pproducts[i][j].replace("=","")[4:])
                else:
                        rc.append(0.)
                        rs.append('')
        pprod_coefs.append(rc)
        pprod_spec.append(rs)

for i in range(len(preactants)):
        pc = []
        ps = []
        for j in range(len(preactants[i])):
                if preactants[i][j] != '':
                        pc.append(float(preactants[i][j][0]))
                        ps.append(preactants[i][j][1:])
                else:
                        pc.append(0.)
                        ps.append('')
        preact_coefs.append(pc)
        preact_spec.append(ps)




wpcoef = prod_coefs + pprod_coefs
wrcoef = react_coefs + preact_coefs
wrspec = react_spec + preact_spec
wpspec = prod_spec + pprod_spec
wrate = react_rate + phot_rate


# variables 1: aori, active_spec, spec_name, mw, init
# variables 2-1: coefA, coefB, coefC, reactants, products, react_rate
# variables 2-2: react_coefs, prod_coefs, react_spec, prod_spec
# variables 3-1: pcoefA, pcoefB, pcoefC, preactants, pproducts, phot_rate
# variables 3-2: preact_coefs, pprod_coefs, preact_spec, pprod_spec

nrxn = 4
nspc = 4
nw = 4
nact = len(active_spec)

# Locate reactant, product index
rxn_ind = np.zeros((nrxn,3+3), dtype='i') - 1  # assume rxns are termolecular
r_ind = np.zeros((nspc,nrxn), dtype='i') - 1
p_ind = np.zeros((nspc,nrxn), dtype='i') - 1
rnum = np.zeros(nspc, dtype='i') - 1
pnum = np.zeros(nspc, dtype='i') - 1

print(spec_name)
print(wrspec)
print(wpspec)
print(nrxn)

wrspec = [['O3P', 'O2', 'M'], ['O3', 'O3P'], ['O3'], ['O2']]
wpspec = [['O3'], ['O2'], ['0O3P', '0O2'], ['0O3P']]



for i in range(nrxn):
    for j in range(len(wrspec[i])):
        if wrspec[i][j] != '':
            try:
                p = spec_name.index(wrspec[i][j])
                rxn_ind[i,j] = p
#                rnum[p] += 1L
                rnum[p] += 1
                r_ind[p,rnum[p]] = i
            except ValueError:
                pass
    for j in range(len(wpspec[i])):
        if wpspec[i][j] != '':
            try:
                p = spec_name.index('O3')
                rxn_ind[i,j+3] = p
#               pnum[p] += 1L
                p_ind[p,pnum[p]] = i
            except ValueError:
                pass

print(rxn_ind)
print(rnum)
print(pnum)
print(r_ind)
print(p_ind)

rxn_ind = [[0,2,3,1,-1,-1],[1,0,-1,-1,-1,-1],[1,-1,-1,0,2,-1],[2,-1,-1,0,-1,-1]]
rnum = [1,1,1,0]
pnum = [-1,-1,-1,-1]
r_ind = [[0,1,-1,-1],[1,2,-1,-1],[0,3,-1,-1],[0,-1,-1,-1]]
p_ind = [[-1,-1,-1,3],[-1,-1,-1,0],[-1,-1,-1,2],[-1,-1,-1,-1]]


