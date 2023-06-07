import numpy as np

T = 298.
p = 101300
R = 8.314
AN = 6.02e+23
CONV = 1e-6*p*AN/(R*T)

class READ_PHOT:
	def __init__(self,inpath):
		self.inpath = inpath
		with open(inpath,'r') as f:
			lis = f.read()
			line = np.array(lis.splitlines())
			start = np.where(line == 'BEGIN')
			done = np.where(line == 'END')
			data1 = line[start[0][0]+1:done[0][0]]
			data2 = line[start[0][1]+1:done[0][1]]
			data3 = line[start[0][2]+1:done[0][2]]
			
			dl1 = len(data1) ; dl2 = len(data2) ; dl3 = len(data3)
			self.dl1 = dl1 ; self.dl2 = dl2 ; self.dl3 = dl3
				
			# data1

			active_spec = []
			spec_name = []
			mw = []
			init = []

			for i in range(dl1):
				active_spec.append(data1[i].split()[0])
				spec_name.append(data1[i].split()[1])
				mw.append(data1[i].split()[2])
				init.append(CONV*float(data1[i].split()[3]))

			self.active_spec = active_spec ; self.spec_name = spec_name ; self.mw = mw ; self.init = init

			# data2

			




