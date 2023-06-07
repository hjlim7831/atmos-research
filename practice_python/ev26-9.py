a1, a2 =  map(int,input().split())
a = set(i for i in range(1,a1+1) if a1%i == 0)
b = set(i for i in range(1,a2+1) if a2%i == 0)

divisor = a & b

result = 0
if type(divisor) == set:
	result = sum(divisor)

print(result)















