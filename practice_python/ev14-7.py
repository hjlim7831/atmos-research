score = list(map(float,input().split()))
if 0<=score[0]<=100 and 0<=score[1]<=100 and 0<=score[2]<=100 and 0<=score[3]<=100:
	me = (score[0] + score[1] + score[2] + score[3])/4.
	if me>= 80:
		print('합격')
	else:
		print('불합격')
else:
	print('잘못된 점수')


