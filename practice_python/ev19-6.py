num = int(input())

for i in range(num):
	print(" "*(num-i-1),"*"*(2*i+1)," "*(num-i-1),sep="")
