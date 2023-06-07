import numpy as np
import sys
import re

inpf = 'chapman_mechanism.dat' # NOTE: MOVE THIS TO NAMELIST
#inpf = 'trop_chemistry.dat'

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
Q = []
Fc = []
reactants = []
products = []
react_rate = []

# Calculating reaction rate & separate products and reactants =======================
l2 = len(data2)
l3 = len(data3)
ltot = l2+l3
tdata = np.append(data2,data3)

re_st = [] # indexes where each reaction start
re_ed = [] # indexes where each reaction end

for i in range(ltot):
	if tdata[i].split()[0] == 'A':
		re_st.append(i)
	elif tdata[i].split()[0][0] == '=':
		re_ed.append(i)

nrd = len(re_st)

for i in range(nrd):
	pr_dum = tdata[re_ed[i]].replace("=","").replace(" ","").split("+")
	while True:
		try:
			pr_dum.remove('')
		except ValueError:
			products.append(pr_dum)
			break

for i in range(nrd):
	re_dum = tdata[re_ed[i]-1].replace(" ","").split("+")
	while True:
		try:
			re_dum.remove('')
		except ValueError:
			reactants.append(re_dum)
			break


#	products.append(data2[re_ed[i]].replace("=","").replace(" ","").split("+"))
#	reactants.append(data2[re_ed[i]-1].replace(" ","").split("+"))

for i in range(nrd):
	ll = re_ed[i]-re_st[i]-1
	A_dum, B_dum, C_dum, Q_dum, Fc_dum = [], [], [], [], []
	for j in range(ll):
		if j == 0:
			A_dum.append(float(tdata[re_st[i]].split()[2]))
			B_dum.append(float(tdata[re_st[i]].split()[3]))
			C_dum.append(float(tdata[re_st[i]].split()[4]))
			Q_dum.append(float(tdata[re_st[i]].split()[5]))
			Fc_dum.append(float(tdata[re_st[i]].split()[6]))
		else:
			A_dum.append(float(tdata[re_st[i]+j].split()[0]))
			B_dum.append(float(tdata[re_st[i]+j].split()[1]))
			C_dum.append(float(tdata[re_st[i]+j].split()[2]))
			Q_dum.append(float(tdata[re_st[i]+j].split()[3]))
			Fc_dum.append(float(tdata[re_st[i]+j].split()[4]))
	coefA.append(A_dum)
	coefB.append(B_dum)
	coefC.append(C_dum)
	Q.append(Q_dum)
	Fc.append(Fc_dum)

#print(products)
#print(reactants)
lp = len(products)
lr = len(reactants)

react_coefs = []
prod_coefs = []
react_spec = []
prod_spec = []

for i in range(lp):
	pc = []
	ps = []
	for j in range(len(products[i])):
		pc_dum = re.findall("\d+\.\d+",products[i][j])[0]
		pc.append(float(pc_dum))
		ps.append(products[i][j].replace(pc_dum,""))
	prod_coefs.append(pc)
	prod_spec.append(ps)

for i in range(lr):
	rc = []
	rs = []
	for j in range(len(reactants[i])):
		rc_dum = reactants[i][j][0]
		if rc_dum.isnumeric():
			rc_dum = re.findall("\d+",reactants[i][j])[0]
			rc.append(float(rc_dum))
			rs.append(reactants[i][j].replace(rc_dum,""))
		else:
			rc.append(1.)
			rs.append(reactants[i][j])
	react_coefs.append(rc)
	react_spec.append(rs)

# variables 1: aori, active_spec, spec_name, mw, init
# variables 2,3-1: coefA, coefB, coefC, reactants, products, react_rate
# variables 2,3-2: react_coefs, prod_coefs, react_spec, prod_spec

nact = len(active_spec)

# Locate reactant, product index
nspc = len(spec_name)

rxn_ind = np.zeros((lr,3+3), dtype='i') - 1  # assume rxns are termolecular
r_ind = np.zeros((nspc,lr), dtype='i') - 1
p_ind = np.zeros((nspc,lr), dtype='i') - 1
rnum = np.zeros(nspc, dtype='i') - 1
pnum = np.zeros(nspc, dtype='i') - 1

#print(spec_name)
#print(react_spec)
#print(prod_spec)
#print(lr)


for i in range(lr):
    for j in range(len(react_spec[i])):
        if react_spec[i][j] != '':
            try:
                p = spec_name.index(react_spec[i][j])
                rxn_ind[i,j] = p
                rnum[p] += 1
                r_ind[p,rnum[p]] = i
            except ValueError:
                pass
    for j in range(len(prod_spec[i])):
        if prod_spec[i][j] != '':
            try:
                p = spec_name.index(prod_spec[i][j])
                rxn_ind[i,j+3] = p
                p_ind[p,pnum[p]] = i
            except ValueError:
                pass

#print(rxn_ind)
#print(rnum)
#print(pnum)
#print(r_ind)
#print(p_ind)


