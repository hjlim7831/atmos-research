import numpy as np

#	we should do like this
# 	ex) import sep_csv as sc
#		b = sc.sep_csv(stndata,rdata)

def ly(year):
	if year%4 == 0 and (year%100 != 0 or year%400 == 0):
		return True
	else:
		return False

def mdays(year):
	if year%4 == 0 and (year%100 != 0 or year%400 == 0):
		return [31,29,31,30,31,30,31,31,30,31,30,31]
	else:
		return [31,28,31,30,31,30,31,31,30,31,30,31]

def yymmdd(syr,smt,sd,eyr,emt,ed,format="yy-mm-dd"):
	s = format
	ss = s.replace("yy","{0:04d}")
	ss = ss.replace("mm","{1:02d}")
	ss = ss.replace("dd","{2:02d}")
	if syr != eyr:
		i1 = smt -1
		i2 = emt -1
		md1 = mdays(syr)
		md2 = mdays(eyr)
		tlen = 0
		for i in range(i1,12):
			if i == i1:
				tlen += (md[i] - sd + 1)
			else:
				tlen += md1[i]
		for i in range(0,i2+1):
			if i == i2:
				tlen += ed
			else:
				tlen += md2[i]
		for i in range(syr+1,eyr):
			if ly(i):
				tlen += 366
			else:
				tlen += 365
		DATE = ["0" for i in range(tlen)]
		yr = syr
		ii = i1
		mt = smt
		dd = sd
		md = mdays(yr)
		for i in range(tlen):
			s = ss.format(yr,mt,dd)
			DATE[i] = s
			if dd == md[ii] and mt == 12:
				ii = 0
				dd = 1
				yr += 1
				mt = 1
				md = mdays(yr)
			elif dd == md[ii]:
				dd = 1
				mt += 1
				ii += 1
			else:
				dd += 1
	elif syr == eyr and smt != emt:
		md = mdays(syr)
		i1 = smt-1
		i2 = emt-1
		tlen = 0
		for i in range(i1,i2+1):
			if i == i1:
				tlen += (md[i] - sd + 1)
			elif i == i2:
				tlen += ed
			else:
				tlen += md[i]
		DATE = ["0" for i in range(tlen)]
		ii = i1
		mt = smt
		dd = sd
		for i in range(tlen):
			s = ss.format(syr,mt,dd)
			DATE[i] = s
			if dd == md[ii]:
				dd = 1
				mt += 1
				ii += 1
			else:
				dd += 1
	elif syr == eyr and smt == emt:
		tlen = ed-sd+1
		DATE = ["0" for i in range(tlen)]
		for i in range(sd,ed+1):
			n = i-sd
			s = ss.format(syr,smt,i)
			DATE[n] = s
	return DATE

def yymmddhh(syr,smt,sd,eyr,emt,ed,format="yy-mm-dd hh:00",zero=0):
	s = format
	ss = s.replace("yy","{0:04d}")
	ss = ss.replace("mm","{1:02d}")
	ss = ss.replace("dd","{2:02d}")
	ss = ss.replace("hh","{3:02d}")
	if syr != eyr:
		i1 = smt -1
		i2 = emt -1
		md1 = mdays(syr)
		md2 = mdays(eyr)
		dlen = 0
		for i in range(i1,12):
			if i == i1:
				dlen += (md1[i] -sd + 1)
			else:
				dlen += md1[i]
		for i in range(0,i2+1):
			if i == i2:
				dlen += ed
			else:
				dlen += md2[i]
		for i in range(syr+1,eyr):
			if ly(i):
				dlen += 366
			else:
				dlen += 365
		tlen = dlen * 24
		DATE = ["0" for i in range(tlen)]
		yr = syr
		ii = i1
		mt = smt
		dd = sd
		md = mdays(yr)
		for i in range(dlen):
			for j in range(0,24):
				hr = j + zero
				s = ss.format(syr,mt,dd,hr)
				DATE[i*24+j] = s
			if dd = md[ii] and mt == 12:
				ii = 0
				dd = 1
				yr += 1
				mt = 1
				md = mdays(yr)
			elif dd == md[ii]:
				dd = 1
				mt += 1
				ii += 1
			else:
				dd += 1
	elif syr == eyr and smt != emt:
		md = mdays(syr)
		i1 = smt-1
		i2 = emt-1
		dlen = 0
		for i in range(i1,i2+1):
			if i == i1:
				dlen += (md[i] - sd + 1)
			elif i == i2:
				dlen += ed
			else:
				dlen == md[i]
		tlen = dlen * 24
		DATE = ["0" for i in range(tlen)]
		ii = i1
		mt = smt
		dd = sd
		for i in range(dlen):
			for j in range(0,24):
				hr = j + zero
				s = ss.format(syr,mt,dd,hr)
				DATE[i*24+j] = s
			if dd = md[ii]:
				dd = 1
				mt += 1
				ii += 1
			else:
				dd += 1
	elif syr == eyr and smt == emt:
		dlen = ed-sd+1
		tlen = dlen * 24
		DATE = ["0" for i in range(tlen)]
		for i in range(sd,ed+1):
			n = i-sd
			for j in range(0,24):
				hr = j + zero
				s = ss.format(syr,smt,i,hr)
				DATE[n*24+j] = s
	return DATE

# we can call: l, dim, same, stnnum
class sep_csv:
	def __init__(self,stndata,rdata,date): #rdata = ndarray
		self.l = len(stndata)
		l = self.l
		dim = 1
		for i in range(l-1):
			if stndata[i] != stndata[i+1]:
				dim += 1
		self.dim = dim
		if dim == 1:
			print('dim = 1, variable(same, stnnum) is not needed.')
			dsize = l 
			self.dsize = dsize
			vsize = len(rdata[0])
			self.vsize = vsize
			mdata = rdata
			rdate = date
			self.mdata = mdata
			self.rdate = rdate
		else:
			same = np.zeros(dim)
			stnnum = np.zeros(dim)
			z = 1
			n = 0
			for i in range(l):
				if i == l-1:
					same[n] = z
					stnnum[n] = stndata[i]
				else:
					if stndata[i] == stndata[i+1]:
						z += 1
					else:
						same[n] = z
						stnnum[n] = stndata[i]
						z = 1
						n += 1
			self.same = same
			self.stnnum = stnnum
			dsize = int(max(same))
			self.dsize = dsize
			vsize = len(rdata[0]) 				 #vsize: number of variables
			self.vsize = vsize
			mdata = np.full((dim,dsize,vsize),np.nan)  #dim: number of stations, dsize: largest size of each station data
			rdate = [[0 for i in range(dsize)] for i in range(dim)]
			n = 0
			for i in range(dim):
				for j in range(int(same[i])):
					if n != l:
						mdata[i][j][:] = rdata[n][:]
						rdate[i][j] = date[n]
						n += 1
			self.mdata = mdata
			self.rdate = rdate

	def date_csv(self,DATE):
		mdata = self.mdata
		rdate = self.rdate
		tlen = self.tlen
		dsize = self.dsize
		dim = self.dim
		vsize = self.vsize
		if tlen >= dsize:
			if dim == 1:
				gdata = np.full((tlen,vsize),np.nan)
				n = 0
				for j in range(tlen):
					if n <dsize:
#						print(DATE[j])
#						print(rdate[n])
						if DATE[j] == rdate[n]:
							gdata[j][:] = mdata[n][:]
							n += 1
			else:
				same = self.same
				mis = tlen - same
				gdata = np.full((dim,tlen,vsize),np.nan)
				for i in range(dim):
					n = 0
					for j in range(tlen):
						if n < dsize:
							if DATE[j] == rdate[i][n]:
								gdata[i][j][:] = mdata[i][n][:]
								n += 1
		else:
			print("ERROR: tlen < dsize")
		self.gdata = gdata
		
				

			
		


		




