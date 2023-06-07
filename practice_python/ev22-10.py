a, b = map(int,input().split())

li = [2**i for i in range(a,b+1)]

li.pop(1)
li.pop(-2)

print(li)


