with open("words.txt","r") as file:
	line = file.readlines()
	for word in line:
		wr  = word.strip('\n')
		if wr[::-1] == wr:
			print(wr)
