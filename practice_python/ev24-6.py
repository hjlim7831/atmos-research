a = list(map(int,input().split(';')))
a.sort(reverse=True)
l = len(a)
for i in range(l):
	b = a[i]
	print('{:>9,}'.format(b))


