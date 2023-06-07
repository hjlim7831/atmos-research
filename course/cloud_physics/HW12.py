import numpy as np
import matplotlib.pyplot as plt
from sympy import symbols, exp, nsolve, Eq, I, cos, cosh, sin, sinh, sqrt, re

K, Ra, q0, q, qst = symbols('K Ra q0 q qst')

eq0 = Eq(cos(q0/2)*(q*sinh(q/2)*(qst**2-K**2)**2*cosh(qst/2)-qst*sinh(qst/2)*(q**2-K**2)**2*cosh(q/2))+cosh(q/2)*(qst*sinh(qst/2)*(q0**2+K**2)**2*cos(q0/2)+q0*sin(q0/2)*(q**2-K**2)**2*cosh(q/2))+cosh(qst/2)*(-q0*sin(q0/2)*(q**2-K**2)**2*cosh(q/2)-q*sinh(q/2)*(q0**2+K**2)**2*cos(q0/2)),0)
eq0 = eq0.subs(q0, K*((Ra/K**4)**(1/3)-1)**(1/2))
eq0 = eq0.subs(q, K*(1+0.5*(Ra/K**4)**(1/3)*(1+I*3**0.5))**0.5)
eq0 = eq0.subs(qst, K*(1+0.5*(Ra/K**4)**(1/3)*(1-I*3**0.5))**0.5)

nst = 1.0
ned = 8.5
npts = int((ned-nst+0.01)/0.01)

Kbox = np.linspace(nst,ned,npts)
print(Kbox)
Rabox = np.zeros(npts)

for i in range(npts):
	print(i)
	eq1 = eq0.subs(K, Kbox[i])
#	sol = nsolve(eq1,Ra, 5000,verify=False)
	sol = nsolve(eq1,Ra, 5000)
	Rabox[i] = re(sol)

plt.plot(Rabox,Kbox)
plt.xlabel('Ra')
plt.ylabel('K')
plt.show()



