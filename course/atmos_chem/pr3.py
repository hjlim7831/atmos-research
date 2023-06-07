import numpy as np

A = np.arange(8)

A = np.where((3<A)&(A<6),2*A,0)
print(A)

