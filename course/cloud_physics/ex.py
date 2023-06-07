import numpy as np

def getnearpos(arr, value):
    l = len(arr)
    arr1 = arr - value
    v = 1e+10
    for i in range(l):
        if arr1[i] != np.nan:
            print(np.abs(arr1[i]))
            print(v)
            if np.abs(arr1[i])<np.abs(v):
                v = arr1[i]
    return v+value



aa = np.array([1,2,3,4,5,6,7,8,9,np.nan])

print(aa)
idx_0 = getnearpos(aa,10)
print(idx_0)








