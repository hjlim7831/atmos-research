import numpy as np
import numpy.linalg as lin
import matplotlib.pyplot as plt
import pandas as pd
import datetime

year = np.array([1930,1940,1949,1955,1960,1970,1980,1990,2000,2005,2010])
pop = np.array([21.058,23.547,20.167,21.502,24.989,30.852,37.407,43.390,45.985,47.041,49.268])
#(millions)

#(a) Interpolate the data by a Lagrange Polynomial. 
# Plot the Polynomial using its values at the data points.
# Use this polynomial to predict (extrapolate) the population at one year intervals up to 2020.
# Tabulate and plot the population prediction.

def Lk(xarr,k,x):
	l = len(xarr)
	out = 1.
	for i in range(l):
		if i != k:
			out *= (x-xarr[i])/(xarr[k]-xarr[i])
	return out

def Lp(xarr,yarr,x):
	l = len(xarr)
	out = 0.
	for i in range(l):
		out += Lk(xarr,i,x)*yarr[i]
	return out

xx0 = np.array([i+1930 for i in range(80)])
yy0 = Lp(year,pop,xx0)

plt.plot(xx0,yy0,'b')
#plt.plot(year,pop)
plt.grid(which='major',axis='both')
plt.xlabel('year')
plt.ylabel('Population (M)')
#plt.show()
plt.savefig("./HW1a-1.png")
plt.close()

xx = np.array([i+1930 for i in range(90)])
yy = Lp(year,pop,xx)

print("population in 2020:",int(yy[-1]),"M")

plt.plot(xx,yy,'b')
#plt.plot(year,pop)
plt.grid(which='major',axis='both')
plt.xlabel('year')
plt.ylabel('Population (M)')
#plt.show()
plt.savefig("./HW1a-2.png")
plt.close()


#(b) Suppose due to some circumstances the Census data for the year 2010 was lost.
# Use Lagrange interpolation and the remaining data to estimate (interpolate) the population up to 2020.
# Plot the resulting polynomial. How accurate is the prediction of the new polynomial for the missing data?
# (You may see zero population at some point. When is the DOOMSDAY?)

LEN = len(year)
year1 = year[:LEN-1]
pop1 = pop[:LEN-1]

xx1 = np.array([i/400+1930 for i in range(90*400)])

yy1 = Lp(year1,pop1,xx1)
yy4 = Lp(year1,pop1,xx0)

plt.plot(xx0,yy4,'b')
#plt.plot(year,pop)
plt.grid(which='major',axis='both')
plt.xlabel('year')
plt.ylabel('Population (M)')
plt.savefig("./HW1b-1.png")
#plt.show()
plt.close()





plt.plot(xx1,yy1,'b')
#plt.plot(year,pop)

#yy1 = Lp(year1,pop1,xx)
print("population in 2020:",int(yy1[-1]),"M")

#plt.plot(xx,yy1,'b')
plt.grid(which='major',axis='both')
plt.xlabel('year')
plt.ylabel('Population (M)')
plt.savefig("./HW1b-2.png")
#plt.show()
plt.close()

#Calculate DOOMSDAY!

def getnearpos(array, value):
	idx = (np.abs(array-value)).argmin()
	return idx

x0 = getnearpos(yy1,0.)
xyr = int(xx1[x0]) # year
xdd = int((xx1[x0]-xyr)*365) # day of year

d = datetime.date(xyr,1,1)
DOOMSDAY = d+ datetime.timedelta(days=xdd)

print("DOOMSDAY:",DOOMSDAY)


#(c) Repeat parts (a) (b) using a cubic spline with your own end condition.
# Discuss your results.


def g2(xarr,yarr):
	l = len(xarr)
	tl = l - 2
	A = np.zeros((tl,tl))
	B = np.zeros(tl)
	for i in range(tl):
		B[i] = (yarr[i+2]-yarr[i+1])/(xarr[i+2]-xarr[i+1])-(yarr[i+1]-yarr[i])/(xarr[i+1]-xarr[i])
		if i == 0:
			A[i,i] = (xarr[i+1]-xarr[i]+xarr[i+2]-xarr[i+1])/3.
			A[i,i+1] = (xarr[i+2]-xarr[i+1])/6.
		elif i == tl-1:
			A[i,i-1] = (xarr[i+1]-xarr[i])/6.
			A[i,i] = (xarr[i+1]-xarr[i]+xarr[i+2]-xarr[i+1])/3.
		else:
			A[i,i-1] = (xarr[i+1]-xarr[i])/6.
			A[i,i] = (xarr[i+1]-xarr[i]+xarr[i+2]-xarr[i+1])/3.
			A[i,i+1] = (xarr[i+2]-xarr[i+1])/6.
	Ai = lin.inv(A)
	return np.dot(Ai, B.T)
#	return A, B, np.dot(Ai, B.T)

#Aa, Bb, g = g2(year,pop)

#print(Aa)
#print(Bb)
#print(g)


def cubic_spline(xarr,yarr,x,opt="Free_end"):
	if opt!="Free_end":
		print("not supported yet..")
	else:
		l = len(xarr)
		g22 = np.zeros(l)
		g22[1:l-1] = g2(xarr,yarr)
		for i in range(l-1):
			if xarr[i] <= x <= xarr[i+1]:
				ii = i
				break
			elif x<xarr[0]:
				ii = 0
				break
			elif xarr[l-1]< x:
				ii = l-2
				break
		gx = g22[ii]/6.*((xarr[ii+1]-x)**3/(xarr[ii+1]-xarr[ii])-(xarr[ii+1]-xarr[ii])*(xarr[ii+1]-x))+g22[ii+1]/6.*((x-xarr[ii])**3/(xarr[ii+1]-xarr[ii])-(xarr[ii+1]-xarr[ii])*(x-xarr[ii]))+yarr[ii]*(xarr[ii+1]-x)/(xarr[ii+1]-xarr[ii])+yarr[ii+1]*(x-xarr[ii])/(xarr[ii+1]-xarr[ii])
		return gx

xx = np.array([i+1930 for i in range(90)])
yy2 = np.zeros(90)
dlen = len(xx)

for i in range(dlen):
	yy2[i] = cubic_spline(year,pop,xx[i])



plt.plot(xx,yy2,'b')
#plt.plot(year,pop)
plt.grid(which='major',axis='both')
plt.xlabel('year')
plt.ylabel('Population (M)')
plt.savefig("./HW1c-1.png")
#plt.show()
plt.close()


yy3 = np.zeros(90)
for i in range(dlen):
	yy3[i] = cubic_spline(year1,pop1,xx[i])

plt.plot(xx,yy3,'b')
#plt.plot(year,pop)
plt.grid(which='major',axis='both')
plt.xlabel('year')
plt.ylabel('Population (M)')
plt.savefig("./HW1c-2.png")
#plt.show()
plt.close()






