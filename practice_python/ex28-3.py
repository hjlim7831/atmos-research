n = int(input())
text = input()
words = text.split()

if len(words) < 1:
	print('wrong')
else:
	n_gram = list(zip(*[words[i:] for i in range(n)]))
	for i in n_gram:
		print(i)



