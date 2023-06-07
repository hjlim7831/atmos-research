import turtle as t
t.shape('classic')
"""
t.fd(100)
t.rt(90)
t.fd(100)
t.rt(90)
t.fd(100)
t.rt(90)
t.fd(100)
for i in range(4):    # 사각형이므로 4번 반복
    t.forward(100)
    t.right(90)
for i in range(5):
	t.forward(100)
	t.right(360/5)

#n = int(input())

n = 6
t.color('red')
t.begin_fill()
for i in range(n):
	t.forward(100)
	t.right(360/n)
t.end_fill()
t.mainloop()
"""

#t.circle(120)

n = 60
t.shape('turtle')
t.speed('fastest')
#for i in range(n):
#    t.circle(120)
#    t.right(360/n)
for i in range(300):
    t.forward(i)
    t.right(95)
