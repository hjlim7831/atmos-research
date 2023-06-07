import numpy as np

#Data input
with open('phot_data.dat','r') as f:
    lis = f.read()
    line = np.array(lis.splitlines())
    start = np.where(line == 'BEGIN')
    done = np.where(line == 'END')
#Coefficients

T = 298.
p = 101300
R = 8.314
AN = 6.02e+23
CONV = 1e-6*p*AN/(R*T)
dt = 10.

#Data split
data1 = line[start[0][0]+1:done[0][0]]
data2 = line[start[0][1]+1:done[0][1]]
data3 = line[start[0][2]+1:done[0][2]]
#for data1
active_spec = []
spec_name = []
mw = []
init = []

for i in range(len(data1)):
    active_spec.append(data1[i].split()[0])
    spec_name.append(data1[i].split()[1])
    mw.append(data1[i].split()[2])
#    init.append(CONV*float(data1[i].split()[3]))
#for data2
coefA = []
coefB = []
coefC = []
reactants = []
products = []
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
react_rate = []
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

# variables 1: active_spec, spec_name, mw, init
# variables 2-1: coefA, coefB, coefC, reactants, products, react_rate
# variables 2-2: react_coefs, prod_coefs, react_spec, prod_spec
# variables 3-1: pcoefA, pcoefB, pcoefC, preactants, pproducts, phot_rate
# variables 3-2: preact_coefs, pprod_coefs, preact_spec, pprod_spec

bb = np.array(react_spec)
print(bb)
cc = np.array([['O3P','O2','M'],['O3P','O3P','O3P']])
print(cc)
#aa = np.where(np.array(react_spec)==spec_name[3])
aa = np.where(cc==spec_name[2])
print(aa)
print(aa[1])
print(cc[aa[1]])

print(bb[np.where(np.array(react_spec)==spec_name[3])])





# ===============================================================================================================
# Functions



def Loss(C):
	ls = len(spec_name)
	f = np.zeros(ls)
	for i in range(ls):
		pass

	return C



def Prod(C):
	ls = len(spec_name)
	f = np.zeros(ls)

	return C




