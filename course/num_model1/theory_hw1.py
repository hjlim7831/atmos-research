import numpy as np

n = 200
xx = np.array([3.14*i/n for i in range(n)])

y1 = 6/(8*np.sin(xx) - np.sin(2*xx))

print(y1)
nn = min(y1)
print(nn)

#y2 = 8*np.sin(xx) - np.sin(2*xx)
#print(y2)




