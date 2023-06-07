import numpy as np
import matplotlib.pyplot as plt

step, size, iteration = 0.02, 200, 20
scale, end, force_range = 0.2, 0.4, 40
#print(scale)

tt = int(end/step)

XX, YY = np.meshgrid(np.linspace(0,scale*size,size),np.linspace(0,scale*size,size))

class semlg:
	def __init__(self,size,step,iteration,scale,force_range):
		#input to output
		self.size, self.step = size, step
		self.iteration, self.scale = iteration, scale
		self.force_range = force_range
		#new
		u, v, r, p = np.zeros((size,size)), np.zeros((size,size)), np.zeros((size,size)), np.zeros((size,size))
		utmp, vtmp, rtmp, ptmp = np.zeros((size,size)), np.zeros((size,size)), np.zeros((size,size)), np.zeros((size,size))
		#initial condition
		for i in range(size):
			p[i,:] = 1e+5
		for i in range(size):
			u[i,:] = i/10
			v[i,:] = i/10

		for i in range(int(size/2-force_range),int(size/2+force_range)):
			for j in range(int(size/2-force_range),int(size/2+force_range)):
				r[i,j] = 1.0

		plt.imshow(r,interpolation=None,vmin=0.,vmax=1.)
		plt.gray()
		plt.savefig("init.png")
		#output
		self.u, self.v, self.r, self.p = u, v, r, p
		self.utmp, self.vtmp, self.rtmp, self.ptmp = utmp, vtmp, rtmp, ptmp


	def advect(self):
		#input
		size, step = self.size, self.step
		scale = self.scale
		u, v, r = self.u, self.v, self.r
		utmp, vtmp, rtmp = self.utmp, self.vtmp, self.rtmp
		#main
		for i in range(1,size-1):
			for j in range(1,size-1):
				posx = np.float64(i)-u[i,j]*step/scale
				posy = np.float64(j)-v[i,j]*step/scale
				x, y = int(posx), int(posy)
				dx, dy = posx-x, posy-y
				a = dx*(u[x+1,y]-u[x,y])+u[x,y]
				b = dx*(u[x+1,y+1]-u[x,y+1])+u[x,y+1]
				utmp[i,j] = dy*(b-a)+a

				a = dx*(v[x+1,y]-v[x,y])+v[x,y]
				b = dx*(v[x+1,y+1]-v[x,y+1])+v[x,y+1]
				vtmp[i,j] = dy*(b-a)+a
			
				a = dx*(r[x+1,y]-r[x,y])+r[x,y]
				b = dx*(r[x+1,y+1]-r[x,y+1])+r[x,y+1]
				rtmp[i,j] = dy*(b-a)+a

		for i in range(size):
			r[i,:] = rtmp[i,:]

		# velocity boundary condition
		utmp[1:size-1,0], vtmp[1:size-1,0] = -utmp[1:size-1,1], -vtmp[1:size-1,1]
		utmp[1:size-1,size-1], vtmp[1:size-1,size-1] = -utmp[1:size-1,size-2], -vtmp[1:size-1,size-2]
		utmp[0,:], vtmp[0,:] = -utmp[1,:], -vtmp[1,:]
		utmp[size-1,:], vtmp[size-1,:] = -utmp[size-2,:], -vtmp[size-2,:]

		# output
		self.utmp, self.vtmp, self.rtmp = utmp, vtmp, rtmp
		self.r = r

	def add_force(self):
		#input
		size, force_range, step = self.size, self.force_range, self.step
		siz2 = int(size/2)
		utmp = self.utmp
		#main
		f = np.float64(10.)
#		for j in range(int(size/2-force_range),int(size/2+force_range)):
#			for i in range(int(size/2),int(size/2+force_range)):
#				utmp[i,j] += step*f
#			for i in range(int(size/2-force_range),int(size/2)):
#				utmp[i,j] += step*f
		utmp[:,0:siz2] += -step*f
		utmp[:,siz2:] += step*f
		ff = np.zeros((size,size))
		ff[:,0:siz2] = -f
		ff[:,siz2:] = f
		plt.imshow(ff)
		plt.savefig("Force_field.png")

		#output
		self.utmp = utmp

	def solve_poisson(self):
		#input
		size, iteration = self.size, self.iteration
		scale = self.scale
		utmp, vtmp = self.utmp, self.vtmp
		p, ptmp = self.p, self.ptmp
		#main
		for t in range(iteration):
			for i in range(1,size-1):
				for j in range(1,size-1):
					b = (utmp[i+1,j]-utmp[i-1,j])/(2*scale)+(vtmp[i,j+1]-vtmp[i,j-1])/(2*scale)
					ptmp[i,j] = (p[i+1,j]+p[i-1,j]+p[i,j+1]+p[i,j-1]-scale*scale*b)/4.0
		
		#Boundary Condition for Pressure
			ptmp[1:size-1,0] = ptmp[1:size-1,1]
			ptmp[1:size-1,size-1] = ptmp[1:size-1,size-2]
			ptmp[0,:] = ptmp[1,:]
			ptmp[size-1,:] = ptmp[size-2,:]

		#update pressure
			for i in range(size):
				p[i,:] = ptmp[i,:]
		#output
		self.ptmp, self.p = ptmp, p

	def subtract_pressure_gradient(self):
		#input
		scale, size = self.scale, self.size
		u, v = self.u, self.v
		utmp, vtmp, ptmp = self.utmp, self.vtmp, self.ptmp
		#main
		for i in range(1,size-1):
			for j in range(1,size-1):
				u[i,j] = utmp[i,j] -(ptmp[i+1,j]-ptmp[i-1,j])/(2*scale)
				v[i,j] = vtmp[i,j] -(ptmp[i,j+1]-ptmp[i,j-1])/(2*scale)
		#Velocity boundary condition
		u[1:size-1,0], v[1:size-1,0] = -u[1:size-1,1], -v[1:size-1,1]
		u[1:size-1,size-1], v[1:size-1,size-1] = -u[1:size-1,size-2], -v[1:size-1,size-2]
		u[0,:], v[0,:] = -u[1,:], -v[1,:]
		u[size-1,:], v[size-1,:] = -u[size-2,:], -v[size-2,:]
		#output
		self.u, self.v = u, v


### Main Code
a, num = 0, 1
b = semlg(size,step,iteration,scale,force_range)
for t in range(tt):
	b.advect()
	b.add_force()
	b.solve_poisson()
	b.subtract_pressure_gradient()
	print(t)

	if a>=5:
		plt.imshow(b.r,interpolation=None,vmin=0.,vmax=1.)
		plt.gray()
		plt.savefig("./HW5-%03d.png"% num)
		plt.show()
		num += 1
		a = 0
	a += 1
	





