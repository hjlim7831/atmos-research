import numpy as np
import matplotlib.pyplot as plt


Rp = 287.047 #J/kg/K
Rst = 8.314 #J/mol/K
T = 273 #K
k0 = 6e-34 * (T/300)**(-3) * 1e-12 #m 6 /molecule 2 /s
g = 9.8 #m/s2
H = Rp*T/g # m
Na = 6.02e23 # molecule

P = np.linspace(1000,500,251) * 100

lifetime = (Rst*T)**2/(k0*0.21*0.99*P**2*Na**2)

plt.plot(lifetime,P/100)
plt.xlabel("life time (s)")
plt.ylabel("Pressure (hPa)")
plt.ylim(1000,500)
plt.show()


