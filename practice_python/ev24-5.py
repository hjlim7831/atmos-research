a = input().split()
l = len(a)
n = 0
for i in range(l):
	d = a[i].strip(" ',.-")
	if d == 'the':
		n += 1
print(n)


