
T = [273.4, 265.5, 277.7, 285.5]
Tflags = [False]*4

n = 0
for i in T:
	if i>273.15:
		Tflags[n] = True
	n += 1
print(Tflags)

