col, row = map(int,input().split())

matrix = []
for i in range(row):
	matrix.append(list(input()))
	
#print(matrix)

for i in range(col):
	for j in range(row):
		if matrix[j][i] == '.': #i-1, i, i+1 ; j-1, j, j+i
			ii = [s for s in range(i-1,i+2) if 0<=s<=col-1]
			jj = [k for k in range(j-1,j+2) if 0<=k<=row-1]
			count = 0
			for i1 in ii:
				for j1 in jj:
					if matrix[j1][i1] == '*':
						count += 1
			matrix[j][i] = count

for j in range(row):
	for i in range(col):
		print(matrix[j][i],end='')
	print()
					

