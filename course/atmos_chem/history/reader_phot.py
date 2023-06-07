import numpy as np
#Data input
with open('photo_stationary.dat','r') as f:
	lis = f.read()
	line = np.array(lis.splitlines())
	start = np.where(line == 'BEGIN')
	done = np.where(line == 'END')
#Coefficients

T = 298.
p = 101300
R = 8.314
AN = 6.02e+23
CONV = 1e-9*p*AN/(R*T)
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
	init.append(CONV*float(data1[i].split()[3]))
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



#make function 'Prod' and 'Loss' which return prodution and loss rate of each chemical species
#Prod-> when they are reactants
#Loss-> when they are products
#x = [NO,NO2,O3P,O3,O2,M] molar concentration
def Loss(C):
	#C: added chemical reactants
	f = [float(0)]*len(spec_name) #I'll return this variable
	if len(C) != len(spec_name):
		print('Wrong length')
	else:
		for k1 in range(len(C)):
			for i1 in range(len(react_spec)):
				for j1 in range(len(react_spec[i1])):
					t1=1.
					if react_spec[i1][j1] == spec_name[k1]:
						for l1 in range(len(react_spec[i1])):
							if react_spec[i1][l1]!='':
								if spec_name.index(react_spec[i1][l1])== ValueError:
        	                        t1 = 0.
                	            else:
									t1 = t1*C[spec_name.index(react_spec[i1][l1])]**react_coefs[i1][l1]
						f[k1]=f[k1]+react_rate[i1]*t1*react_coefs[i1][j1]
		for k2 in range(len(C)):
			for i2 in range(len(preact_spec)):
				for j2 in range(len(preact_spec[i2])):
					t2=1.
					if preact_spec[i2][j2] == spec_name[k2]:
						for l2 in range(len(preact_spec[i2])):
							if preact_spec[i2][l2]!='':
								if spec_name.index(preact_spec[i2][l2])== ValueError:
                	                t2 = 0.
                        	    else:
									t2 = t2*C[spec_name.index(preact_spec[i2][l2])]**preact_coefs[i2][l2]
						f[k2]=f[k2]+phot_rate[i2]*t2*preact_coefs[i2][j2]
	return np.asarray(f)

def lamb(C):
	f = [float(0)]*len(spec_name) #I'll return this variable
        if len(C) != len(spec_name):
                print('Wrong length')
        else:
                for k1 in range(len(C)):
                        for i1 in range(len(react_spec)):
                                for j1 in range(len(react_spec[i1])):
                                        t1=1.
                                        if react_spec[i1][j1] == spec_name[k1]:
                                                for l1 in range(len(react_spec[i1])):
                                                        if react_spec[i1][l1]!='':
                                                                if spec_name.index(react_spec[i1][l1])== ValueError:
                                                                        t1 = 0.
                                                                else:
                                                                        t1 = t1*C[spec_name.index(react_spec[i1][l1])]**react_coefs[i1][l1]
						if C[k1]!=0:
                	       	f[k1]=f[k1]+react_rate[i1]*t1*react_coefs[i1][j1]/C[k1]
                for k2 in range(len(C)):
                        for i2 in range(len(preact_spec)):
                                for j2 in range(len(preact_spec[i2])):
                                        t2=1.
                                        if preact_spec[i2][j2] == spec_name[k2]:
                                                for l2 in range(len(preact_spec[i2])):
                                                        if preact_spec[i2][l2]!='':
                                                                if spec_name.index(preact_spec[i2][l2])== ValueError:
                                                                        t2 = 0.
                                                                else:
                                                                        t2 = t2*C[spec_name.index(preact_spec[i2][l2])]**preact_coefs[i2][l2]
						if C[k2]!=0:
                           	f[k2]=f[k2]+phot_rate[i2]*t2*preact_coefs[i2][j2]/C[k2]
        return np.asarray(f)

def Prod(C):
        #C: added chemical reactants
        f2 = [float(0)]*len(spec_name) #I'll return this variable
        if len(C) != len(spec_name):
                print('Wrong length')
        else:
                for k1 in range(len(C)):
                        for i1 in range(len(prod_spec)):
                                for j1 in range(len(prod_spec[i1])):
										t1=1.
                                        if prod_spec[i1][j1] == spec_name[k1]:
												for l1 in range(len(react_spec[i1])):
                                   		             	if react_spec[i1][l1]!='':
																if spec_name.index(react_spec[i1][l1])== ValueError:
																		t1 = 0.
																else:
                                                       	        		t1 = t1*C[spec_name.index(react_spec[i1][l1])]**react_coefs[i1][l1]
						f2[k1]=f2[k1]+react_rate[i1]*t1*prod_coefs[i1][j1]
		for k2 in range(len(C)):
			for i2 in range(len(pprod_spec)):
                for j2 in range(len(pprod_spec[i2])):
					t2=1.
                    if pprod_spec[i2][j2] == spec_name[k2]:
						for l2 in range(len(preact_spec[i2])):
                       		if preact_spec[i2][l2]!='':
								if spec_name.index(preact_spec[i2][l2])== ValueError:
									t2 = 0.
								else:
                               		t2 = t2*C[spec_name.index(preact_spec[i2][l2])]**preact_coefs[i2][l2]
						f2[k2]=f2[k2]+phot_rate[i2]*t2*pprod_coefs[i2][j2]
        return np.asarray(f2)

