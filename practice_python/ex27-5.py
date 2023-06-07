# My Code
"""
with open("words0.txt","r") as file:
	count = 0
	line = None
	while line != '':
		line = file.readline()
		if len(line)<=10:
			count += 1
	print(count)
"""
# Example
with open("words0.txt","r") as file:
	count = 0
	words = file.readlines()
	for word in words:
		if len(word.strip('\n')) <=10:
			count += 1
	print(count)
