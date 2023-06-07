import numpy as np
import copy
import sys




# Read all the lines of chemical tables.
tblname = "./trop_chemistry.dat"
tbl = open( tblname , 'r')
lns = tbl.readlines()
bgn_ln = []
end_ln = []
i = 0
for ln in lns:
	if ln.strip() == 'BEGIN':
		bgn_ln.append(i)
	elif ln.strip() == 'END':
		end_ln.append(i)
	i = i + 1




# Separate lines to "species part", "Non-photolysis reaction part", "photolysis reaction part".
# This part assumes that all table contents only consist of those 3 parts.
specs_lins = lns[bgn_ln[0]+1:end_ln[0]]
nonph_lins = lns[bgn_ln[1]+1:end_ln[1]]
photo_lins = lns[bgn_ln[2]+1:end_ln[2]]
react_lins = nonph_lins + photo_lins



# Make "specs" array from "specs_lins".
conc = np.zeros(len(specs_lins), dtype='float64')
act_specs = []
inact_specs = []
specs = []
Molecweight = []
for i in range(0, len(specs_lins)):
	pie = specs_lins[i].split()
	specs.append(pie[1])
	Molecweight.append(np.double(pie[2]))
	conc[i] = np.double(pie[3])
	if pie[0].strip()=='A':
		act_specs.append(pie[1])
	else:
		inact_specs.append(pie[1])




# Make "react_arr" array from "react_lins".
A = []
B = []
C = []
Fc = []
k_num = []
react_spec = []
react_coef = []
prod_num = []
prod_spec = []
prod_coef = []

for i in range(0, len(react_lins)):
	pie = react_lins[i].split()
	A_tmp = []
	B_tmp = []
	C_tmp = []
	Fc_tmp = []

	# If "Active" reaction.
	if pie[0].strip()=='A':

		# Read all different "k".
		rxn_num = int(pie[5])+1
		for j in range(0,rxn_num):
			pie1 = react_lins[i+j].split()
			A_tmp.append(np.double(pie1[2]))
			B_tmp.append(np.double(pie1[3]))
			C_tmp.append(np.double(pie1[4]))
			Fc_tmp.append(np.double(pie1[6]))

		A.append(A_tmp)
		B.append(B_tmp)
		C.append(C_tmp)
		Fc.append(Fc_tmp)
		k_num.append( rxn_num )

		# Read reactant part.
		# it assumes there is no species more than one.
		r_coef = []
		pie1 = react_lins[i + rxn_num].split()
		while '+' in pie1:
			pie1.remove('+')
		for j in range(0,len(pie1)):
			r_coef.append(np.double(1.0))
		react_spec.append(pie1)	
		react_coef.append(r_coef)
		
		
		# Read product part.
		p_spec = []
		p_coef = []
		pie1 = react_lins[i + rxn_num + 1].split()
		while '+' in pie1:
			pie1.remove('+')
		for j in range(0,len(pie1)):
			p_coef.append(np.double(pie1[j][1:5]))
			p_spec.append(pie1[j][5:])
		prod_spec.append(p_spec)
		prod_coef.append(p_coef)


	else:
		continue



# Make "react_arr", "prod_arr", "loss_arr".
# this part assumes there is only one "k" value for one chemical equation.
n_specs = len(specs)
n_react = len(k_num)
react_arr = np.zeros( (n_react, n_specs) , dtype="float64" )
prod_arr = np.zeros( (n_react, n_specs) , dtype="float64" )
loss_arr = np.zeros( (n_react, n_specs) , dtype="float64" )
for i in range(0, n_react):

	# for "react_arr" & "loss_arr".
	for j in range(0, len(react_spec[i])):
		idx = specs.index(react_spec[i][j])
		react_arr[i,idx] = react_coef[i][j]
		if react_spec[i][j] in act_specs:
			loss_arr[i,idx] = react_coef[i][j]

	# for "prod_arr".
	for j in range(0, len(prod_spec[i])):
		idx = specs.index(prod_spec[i][j])
		prod_arr[i,idx] = prod_coef[i][j]



# Make "react_arr_gam"
react_arr_gam = np.zeros( (n_specs, n_react, n_specs) , dtype="float64" )
for i in range(0, n_specs):
	react_arr_gam[i,:,:] = copy.deepcopy(react_arr)
	react_arr_gam[i,:,i] = 0.0 
	
print(react_arr)
print(react_arr_gam)
print(prod_arr)
print(loss_arr)


#print(react_arr_gam.shape)
#print(react_arr)
#print(prod_arr)
#print(loss_arr)
#print(A)
#print(B)
#print(C)
#print(Fc)
#print(k_num)
#print(react_spec)
#print(react_coef)
#print(prod_spec)
#print(prod_coef)
#print(conc)
