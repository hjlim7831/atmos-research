#My Code
"""
with open("words.txt","r") as file:
	line = file.readline().split()
	l = len(line)
	for word in line:
		word = word.strip(".,")
		for al in word:
			if al == "c":
				print(word)
				break
"""
# Example
with open("words.txt","r") as file:
	line = file.readline().split()
	l = len(line)
	for word in line:
		for al in word:
			if al == "c":
				print(word.strip(',.'))
				break

